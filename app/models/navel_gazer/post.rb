module NavelGazer
  class Post < ActiveRecord::Base
    set_table_name :posts
    
    belongs_to :user
    belongs_to :linked_account
  
    has_many :media, 
      :class_name => "Media",
      :dependent => :destroy
    has_many :photos,
      :class_name => "Media",
      :conditions => {:embed_type => 'photo'}
  

    validate :source_id, 
             :uniqueness => { :scope => :linked_account_id }
    
    def serializable_hash options = {}
      hash = super (options || {}).merge(:include => [:linked_account, :photos])
      hash[:source_created_at] = source_created_at.strftime("%b %e, %Y")
      hash
    end
  
    # Switch to STI?
    def links
      case linked_account.class.name
      when "Twitter"
        content.links
      when "Banters"
        [permalink]
      end
    end
  
  end
end