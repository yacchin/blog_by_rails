class UsersController < ApplicationController
  def index
  	get_status

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  def show
  	get_status
  	@user = User.where(:id => params[:id]).first
    @posts = Post.where(:user_id => params[:id]).order('created_at DESC').page(params[:page]).per(5)
    @labels = ["<span class=\"label\">","<span class=\"label label-success\">","<span class=\"label label-warning\">","<span class=\"label label-important\">","<span class=\"label label-info\">"]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def new
    get_status
    @user = User.new
    @select_tags = {}
    @select_users = {}

    @tags.each do |tag|
      @select_tags = @select_tags.merge(tag.name => tag.id)
    end

    @users.each do |user|
      @select_users = @select_users.merge(user.name => user.id)
    end
  end

  def create

    puts params

    get_status
    @user = User.new
    @user.name = params[:user][:name]
    @user.password = params[:user][:password]

    if !User.where(:name => @user.name).first.blank?
      redirect_to :controller => "users", :action => "new", notice: 'The same name is already registered.'  and return
    elsif @user.password != params[:password_confirm]
      redirect_to :controller => "users", :action => "new", notice: 'Password is not match.'  and return
    end

    @user.save!
    respond_to do |format|
      format.html { redirect_to :controller => "sessions", :action => "new", notice: 'Post was successfully created.' }
      format.json { render json: @user, status: :created, location: @user }
    end
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
