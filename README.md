# Setup

Create a new project
'''rails g your-project-name'''

Include navel_gazer in the Gemfile
<pre>
  gem 'omniauth-identity'
  gem 'omniauth-instagram'
  gem 'omniauth-twitter', '0.0.8'
  gem 'omniauth-banters', :git => "git://github.com/becarella/omniauth-banters.git"

  gem 'hbs'
  gem 'handlebars_assets'

  gem "render_or_redirect", :git => 'git@github.com:becarella/render_or_redirect.git'
  gem 'let_me_in', :git => 'git@github.com:becarella/let_me_in.git'
  gem 'navel_gazer', :git => 'git@github.com:becarella/navel_gazer.git'
</pre>

Register api keys for:
* Banters (optional) https://banters.com/api/apps
* Twitter (optional) https://dev.twitter.com/apps
* Instagram (optional) http://instagr.am/developer/
* Embedly (required) http://embed.ly/docs

Store the keys in environment variables. On localhost, edit .bash_profile:
<pre>
  export BANTERS_KEY="xyz"
  export BANTERS_SECRET="abc"
  export TWITTER_KEY="xyz"
  export TWITTER_SECRET="abc"
  export INSTAGRAM_KEY="xyz"
  export INSTAGRAM_SECRET="abc"
  export EMBEDLY_KEY="whatevs"
</pre>

To host on heroku, register a new application and install the keys. https://devcenter.heroku.com/articles/config-vars
<pre>
  heroku config:add BANTERS_KEY=xyz
  ...
</pre>

Install the database migrations into your projects:
<pre>
  rake let_me_in_engine:install:migrations
  rake navel_gazer_engine:install:migrations
  rake db:migrate
</pre>
  
Add these routes to routes.rb
<pre>
  root :to => 'navel_gazer/posts#index'
  match 'posts' => 'navel_gazer/posts#index'
  match 'signin' => 'let_me_in/sessions#new'
  match 'signout' => 'let_me_in/sessions#destroy'
  match 'auth/:provider/connect' => "let_me_in/auth#connect", :via => :get
  match 'auth/:provider/:id' => 'let_me_in/auth#disconnect', :via => :delete
  match 'auth/:provider/callback' => 'let_me_in/auth#callback'
  match 'auth(/:provider)/failure' => 'let_me_in/auth#failure'
  match 'accounts' => 'let_me_in/linked_accounts#index', :as => 'accounts'
  match 'accounts' => 'let_me_in/linked_accounts#index', :as => 'post_login'
</pre>

Create a file in config/initializers/omniauth.rb
<pre>
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
  if Banters.available?
    provider :banters, Banters.key, Banters.secret, :name => "banters" 
    LetMeIn::Engine.config.account_types << Banters
  end
  
  if Instagram.available?
    provider :instagram, Instagram.key, Instagram.secret, :display => 'touch', :name => "instagram"
    LetMeIn::Engine.config.account_types << Instagram
  end
  
  if Twitter.available?
    provider :twitter, Twitter.key, Twitter.secret, :name => "twitter"
    LetMeIn::Engine.config.account_types << Twitter
  end

  provider :identity, :fields => [:username, :email], :model => User, 
    :on_failed_registration => lambda { |env| 
      AuthController.action(:failure).call(env) 
    }
end

OmniAuth.config.logger = Rails.logger
</pre>

Create the file app/models/user.rb:
<pre>
class User < NavelGazer::User
end
</pre>

Run rails c and do:
<pre>
User.create(:username=>'USERNAME', :email=>'EMAIL', :password=>'PASSWORD', :password_confirmation=>'PASSWORD')
</pre>
