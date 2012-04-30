module NavelGazer
  class LinkedAccount < ActiveRecord::Base
    include LetMeIn::LinkedAccounts::Account
    
    set_table_name :linked_accounts
    
    belongs_to_user
    
    has_many :posts, :order => "source_id+0 DESC"
    
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