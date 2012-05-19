module NavelGazer
  class PostsController < ApplicationController
    def index
      method = params.delete(:method) || :grouped_by_day_and_type
      posts = NavelGazer::Post.send(method, params)
      render_or_redirect posts
    end
  end
end
