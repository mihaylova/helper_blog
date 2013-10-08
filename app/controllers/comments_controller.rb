class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :set_post
  before_filter :is_author?, only: [:edit, :update, :destroy]

  def edit
    respond_to do |format|
      format.js
    end
  end


  def create
    @comment = Comment.new(comment_params)
    if (user_signed_in? || verify_recaptcha) && @comment.save
      respond_to do |format|
        format.js
      end
    end
  end


  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.js
    end
  end

  private

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_post
      @post = Post.find(params[:post_id])
    end

    def comment_params
      parameters = params.require(:comment).permit(:text, :rating, :user_name)
      parameters.merge!({post_id: @post.id})
      parameters.merge!({user_id: current_user.id}) if user_signed_in?
      parameters
    end
    
    def is_author?
      @comment.user == current_user
    end
end
