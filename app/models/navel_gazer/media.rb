module NavelGazer
  class Media < ActiveRecord::Base
    set_table_name :media
    
    belongs_to :post
  
    def self.fetch_for_posts posts=[]
      embedly_api = Embedly::API.new :key => ENV['EMBEDLY_KEY']
    
      posts.each do |post|
        links = post.links
        next if links.empty?
        objs = embedly_api.oembed(
          :urls => links,
          :maxWidth => 300
        )
      
        objs.collect{|o| o.marshal_dump}.each do |obj|
          next if obj[:type] == 'error'
         media = Media.find_or_initialize_by_post_id(:post_id => post.id)
         media.update_attributes!(
          :post_id => post.id,
          :embed_type => obj[:type],
          :version => obj[:version],
          :title => obj[:title],
          :author_name => obj[:author_name],
          :author_url => obj[:author_url],
          :provider_name => obj[:provider_name],
          :provider_url => obj[:provider_url],
          :cache_age => obj[:cache_age],
          :thumbnail_url => obj[:thumbnail_url],
          :thumbnail_width => obj[:thumbnail_width],
          :thumbnail_height => obj[:thumbnail_height],
          :description => obj[:description],
          :url => obj[:url],
          :width => obj[:width],
          :height => obj[:height],
          :html => obj[:html] || obj[:url])
        end
      end
    end
  
  end
end
