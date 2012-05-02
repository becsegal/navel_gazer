# Setup

Create a new project
'''rails g your-project-name'''

Include navel_gazer in the Gemfile
'''gem navel_gazer'''

Register api keys for:
* Banters (optional) https://banters.com/api/apps
* Twitter (optional) https://dev.twitter.com/apps
* Instagram (optional) http://instagr.am/developer/
* Embedly (required) http://embed.ly/docs

Store the keys in environment variables. On localhost, edit .bash_profile:
  export BANTERS_KEY="xyz"
  export BANTERS_SECRET="abc"
  export TWITTER_KEY="xyz"
  export TWITTER_SECRET="abc"
  export INSTAGRAM_KEY="xyz"
  export INSTAGRAM_SECRET="abc"
  export EMBEDLY_KEY="whatevs"
  
To host on heroku, register a new application and install the keys. https://devcenter.heroku.com/articles/config-vars
  heroku config:add BANTERS_KEY=xyz
  ...
