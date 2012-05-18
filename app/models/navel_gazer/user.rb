module NavelGazer
  class User < OmniAuth::Identity::Models::ActiveRecord
    include LetMeIn::LinkedAccounts::Identity
    attr_accessible :name, :description
  
    def serializable_hash options={}
      super :only => [:username, :name, :description, :created_at],
            :include => :linked_accounts
    end
  end
end