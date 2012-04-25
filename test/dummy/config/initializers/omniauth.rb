
Rails.application.config.middleware.use OmniAuth::Builder do
  if LetMeIn::Banters.available?
    provider :banters, LetMeIn::Banters.key, LetMeIn::Banters.secret, :name => "banters" 
  end
  
  if LetMeIn::Instagram.available?
    provider :instagram, LetMeIn::Instagram.key, LetMeIn::Instagram.secret, :display => 'touch', :name => "instagram"
  end
  
  if LetMeIn::Twitter.available?
    provider :twitter, LetMeIn::Twitter.key, LetMeIn::Twitter.secret, :name => "twitter"
  end
  
  provider :identity, :fields => [:username, :email], :model => LetMeIn::User, 
    :on_failed_registration => lambda { |env| 
      AuthController.action(:failure).call(env) 
    }
end
