$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "navel_gazer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "navel_gazer"
  s.version     = NavelGazer::VERSION
  s.authors     = ["Becky Carella"]
  s.email       = ["becarella@gmail.com"]
  s.homepage    = "https://github.com/becarella/navel_gazer"
  s.summary     = "Import and display posts from misc social media sites."
  s.description = "Import and display posts from misc social media sites."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "rest-client"
  s.add_dependency "embedly"

  s.add_development_dependency "sqlite3"
end
