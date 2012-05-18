# Failed idenity login was showing a Rails error page, not redirecting to /auth/identity/failure
# https://github.com/intridea/omniauth-identity/issues/25
# Hack fix from: http://inside.oib.com/getting-more-information-from-omniauth-exceptions/
OmniAuth.config.on_failure do |env|
  exception = env['omniauth.error']
  error_type = env['omniauth.error.type']
  strategy = env['omniauth.error.strategy']
  
  new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{error_type}"
  
  [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
end


Rails.application.config.middleware.use OmniAuth::Builder do
  if NavelGazer::Banters.available?
    provider :banters, NavelGazer::Banters.key, NavelGazer::Banters.secret, :name => "banters" 
    LetMeIn::Engine.config.account_types << NavelGazer::Banters
  end
  
  if NavelGazer::Instagram.available?
    provider :instagram, NavelGazer::Instagram.key, NavelGazer::Instagram.secret, :display => 'touch', :name => "instagram"
    LetMeIn::Engine.config.account_types << NavelGazer::Instagram
  end
  
  if NavelGazer::Twitter.available?
    provider :twitter, NavelGazer::Twitter.key, NavelGazer::Twitter.secret, :name => "twitter"
    LetMeIn::Engine.config.account_types << NavelGazer::Twitter
  end
  
  provider :identity, :fields => [:username, :email], :model => NavelGazer::User, 
    :on_failed_registration => lambda { |env| 
      AuthController.action(:failure).call(env) 
    }
end
