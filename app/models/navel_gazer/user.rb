module NavelGazer
  class User < LetMeIn::User
    set_table_name :users
    attr_accessible :name, :description
    
    def serializable_hash options={}
      super :only => [:username, :name, :description, :created_at],
            :include => :linked_accounts
    end
  end
end