module NavelGazer
  class PostsController < ApplicationController
    def index
      posts = Post.includes(:linked_account, :photos)
                  .order("source_created_at DESC")
                  .limit((params[:limit] || 20).to_i)
                  .offset((params[:offset] || 0).to_i)
                  .all
      render_or_redirect posts
    end
  end
end
