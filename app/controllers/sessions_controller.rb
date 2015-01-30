class SessionsController < ApplicationController
  def create
    puts params
    user = User.find(:first, :conditions => ["name = ? and password =?",params[:user][:name],params[:user][:password]])
    unless user.nil?
      session[:user_id] = user.id
      redirect_to_posts
    else
      puts @from_post_new_flg
      redirect_to :controller => "post", :action => "new", alert: 'success!' if @from_post_new_flg
      redirect_to :action => "new", alert: 'success!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to_posts
  end

  def new
    get_status
    @select_tags = {}
    @select_users = {}

    @tags.each do |tag|
      @select_tags = @select_tags.merge(tag.name => tag.id)
    end

    @users.each do |user|
      @select_users = @select_users.merge(user.name => user.id)
    end
  end

  private
  def redirect_to_posts
    redirect_to :controller => 'posts', :action => 'index'
  end

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