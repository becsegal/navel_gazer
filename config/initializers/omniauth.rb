
Rails.application.config.middleware.use OmniAuth::Builder do
  if NavelGazer::Banters.available?
    provider :banters, NavelGazer::Banters.key, NavelGazer::Banters.secret, :name => "banters" 
  end
  
  if NavelGazer::Instagram.available?
    provider :instagram, NavelGazer::Instagram.key, NavelGazer::Instagram.secret, :display => 'touch', :name => "instagram"
  end
  
  if NavelGazer::Twitter.available?
    provider :twitter, NavelGazer::Twitter.key, NavelGazer::Twitter.secret, :name => "twitter"
  end
  
  provider :identity, :fields => [:username, :email], :model => NavelGazer::User, 
    :on_failed_registration => lambda { |env| 
      AuthController.action(:failure).call(env) 
    }
end
