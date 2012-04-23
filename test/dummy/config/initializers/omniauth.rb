
Rails.application.config.middleware.use OmniAuth::Builder do
  puts "omniauth.rb"
  if Banters.available?
    puts "banters available"
    provider :banters, Banters.key, Banters.secret 
  end
  
  if Instagram.available?
    provider :instagram, Instagram.key, Instagram.secret, :display => 'touch'
  end
  
  if Twitter.available?
    provider :twitter, Twitter.key, Twitter.secret 
  end
  
  provider :identity, :fields => [:username, :email], :model => LetMeIn::User, 
    :on_failed_registration => lambda { |env| 
      AuthController.action(:failure).call(env) 
    }
end
