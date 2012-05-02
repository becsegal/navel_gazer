module NavelGazer
  class Engine < Rails::Engine
    paths["app/views"] << "app/assets/templates/navel_gazer"
    config.autoload_paths << dir = File.expand_path("../ext/", __FILE__)
    Dir[File.join(dir, "*.rb")].each {|l| require l }
  end
  
  # hack from http://tumblr.teamon.eu/post/898063470/better-scoped-rails-engines-routing
  # b/c I couldn't get named routes working without the isolated namespace
  module Routes
    def self.draw(map)
      map.instance_exec do
        root :to => 'posts#index'
      end
    end
  end
end
