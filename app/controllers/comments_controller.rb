class CommentsController < ApplicationController

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    get_status
    @comment = Comment.new
    @comment.body = params[:comment][:body]
    @comment.post_id = params[:post_id]
    @comment.user_id = session[:user_id]
    @comment.save!

    @comments = Comment.where({:post_id => params[:post_id]})

    @post = Post.find(params[:post_id])

    respond_to do |format|
      format.html { redirect_to @post, notice: 'Comment was successfully created.' }
      format.json { render json: @comment, status: :created, location: @comment }
    end
  end

  def update
  end

  def destroy
  end

  def search
  end

  private
  def get_status
    @tags = Tag.all
    @users = User.all
    @tag_counter = {}
    @tags.each do |tag|
      @tag_counter = @tag_counter.merge({tag.id => Tagging.where({:tag_id => tag.id}).size})
    end
    @user_counter = {}
    @users.each do |user|
      @user_counter = @user_counter.merge({user.id => Post.where({:user_id => user.id}).size})
    end  
  end

end