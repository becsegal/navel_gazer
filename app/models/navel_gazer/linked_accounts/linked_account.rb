module NavelGazer
  class LinkedAccount < LetMeIn::LinkedAccount
    set_table_name :linked_accounts
    
    has_many :posts, :order => "source_id+0 DESC"
  
    def serializable_hash options={}
      hash = super :only => [:id, :app_user_id, :app_username, :image_url, :url, :user_id]
      hash[:type] = type.downcase
      hash[:connected] = token?
      hash
    end
  
    def import_backlog
      last_post = posts.last
      before_id = last_post ? last_post.source_id : nil
      options = {:count => 99, :include_rt => 1}
      keep_going = true
      while keep_going
        count = import(options.merge(:before_id => before_id))
        new_last_post = posts.reorder("source_id ASC").first
        keep_going = count && count > 0 && new_last_post != last_post
        last_post = new_last_post
        before_id = last_post ? last_post.source_id : nil
      end
    end
  
    def import options={}
      false
    end
  
  end
end