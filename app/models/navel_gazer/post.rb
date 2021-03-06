module NavelGazer
  class Post < ActiveRecord::Base
    set_table_name :posts
    
    DEFAULT_LIMIT = 25
    
    belongs_to :user
    belongs_to :linked_account
    
    attr_accessor :additional_count
  
    has_many :media, 
      :class_name => "Media",
      :dependent => :destroy

    has_many :render_media,
      :class_name => "Media",
      :conditions => {:embed_type => ['audio','photo','video']}

    has_many :photos,
      :class_name => "Media",
      :conditions => {:embed_type => 'photo'}

    validate :source_id, 
             :uniqueness => { :scope => :linked_account_id }
             
    def serializable_hash options = {}
      hash = super (options || {}).merge(:include => [:linked_account, :render_media, :photos])
      hash[:source_created_at] = source_created_at.strftime("%b %e, %Y")
      hash[:additional_count] = additional_count if additional_count
      hash
    end
    
    def self.ungrouped(options={})
      posts = includes(:linked_account, :photos)
              .order("source_created_at DESC")
              .limit((options[:limit] || DEFAULT_LIMIT).to_i)
              .offset((options[:offset] || 0).to_i)
              .all
    end
    
    def self.grouped_by_day_and_type(options={})
      dates = active_dates(options)
      query = %Q{ SELECT max(id) as id, linked_account_id, date_trunc('day', source_created_at) AS pdate, count(*)
                  FROM posts
                  WHERE date_trunc('day', source_created_at) IN (?)
                  GROUP BY pdate, linked_account_id}
      post_data = ActiveRecord::Base.raw_query_flat([query, dates])
      posts = includes(:linked_account, :photos)
              .where([ "id in (?)", post_data.collect{|p| p['id'].to_i} ])
              .order("source_created_at DESC, linked_account_id DESC")
              .all
      
      posts_by_date = []
      dates.each do |d| 
        date = Date.parse(d.to_s)
        entry = {:date => date.strftime('%Y-%m-%d'), :pretty_date => date.strftime('%b %e, %Y')}
        dated_posts = posts.select do |p| 
          Date.parse(p['source_created_at'].midnight.to_s) == date
        end
        posts -= dated_posts
        entry[:accounts] = []
        dated_posts.each do |p|
          count = post_data.select{|pd| pd['id'].to_i == p.id}[0]['count'].to_i - 1
          entry[:accounts] << { :type => p.linked_account.class.short_name.downcase, 
                                :linked_account_id => p.linked_account.id,
                                :posts => [p], 
                                :additional_count => count}
        end
        posts_by_date << entry
      end
      posts_by_date
    end

    def self.by_account_and_date(options={})
      return [] if options[:date].nil? || options[:linked_account_id].nil? || Date.parse(options[:date].to_s).nil?
      self.includes(:linked_account, :photos)
          .where(:linked_account_id => options[:linked_account_id].to_i)
          .where(["date_trunc('day', source_created_at) = ?", Date.parse(options[:date])])
          .order('id DESC')
          .all
    end
    
    def self.active_dates(options={})
      query = "SELECT date_trunc('day', source_created_at) AS pdate FROM posts"
      if options[:since]
        query += " WHERE source_created_at > ?" 
      elsif options[:before]
        query += " WHERE source_created_at < ?" 
      end
      query += " GROUP BY pdate ORDER BY pdate DESC LIMIT ?"
      limit = options[:limit] || Finders::DEFAULT_LIMIT
      query_array = [query, options[:since], options[:before], limit].compact!
      post_data = ActiveRecord::Base.raw_query_flat(query_array)
      post_data.collect{|d| d['pdate']}.sort{|a,b| b <=> a}
    end
  
    # Switch to STI?
    def links
      case linked_account.class.short_name
      when "Twitter"
        content.links
      when "Banters"
        [permalink]
      end
    end
  
  end
end
