module NavelGazer
  class PostsController < ApplicationController
    def index
      method = params.delete(:method) || :grouped_by_day_and_type
      posts = NavelGazer::Post.send(method, params)
      options = {}
      if request.xhr?
        @data = posts
        render "index_#{method}_ajax", :layout => false
      else
        render_or_redirect posts, options
      end
    end
  end
end
