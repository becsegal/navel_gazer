module NavelGazer
  class HandlebarsConfig

    def self.register_partial(partial_name, file_name)
      Handlebars.handlebars.registerPartial(partial_name, Handlebars.compile(File.open(file_name).read))
    end 

    def self.register_helper name, fn
      register_helper name, fn
    end

    def self.register_partials
      path = File.expand_path("../../../app/assets/templates/navel_gazer", __FILE__)
      register_partial("posts", "#{path}/posts/_posts.jst.hbs")
      register_partial("post", "#{path}/posts/_post.jst.hbs")
    end

    def self.register_helpers 
      # register_helper "nor", lambda do |a, b, context, options| 
      #   (a || b) ? options.inverse(context) : options.fn(context) 
      # end
      # register_helper "eq",  lambda do |a, b, context, options| 
      #   (a == b) ? options.fn(context) : options.inverse(context)
      # end
    end
  end
end