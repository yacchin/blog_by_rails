class PostsController < ApplicationController

  def index
    get_status
    @posts = Post.order('created_at DESC').page(params[:page]).per(5)
    @new_blog = Post.find(:all,:order => 'created_at desc').first
    @labels = ["<span class=\"label\">","<span class=\"label label-success\">","<span class=\"label label-warning\">","<span class=\"label label-important\">","<span class=\"label label-info\">"]
  end

  def show
    get_status
    @post = Post.find(params[:id])
    @selected_tags = []
    @user = User.find(@post.user_id)
    @comments = Comment.where({:post_id => params[:id]})

    selected_taggings = Tagging.where({:post_id => params[:id]})

    selected_taggings.each do |tag|
      @selected_tags << Tag.where({:id => tag.tag_id}).first
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def new
    @from_post_new_flg = true
    redirect_to :controller => "sessions", :action => "new" unless session[:user_id]
    get_status
    @post = Post.new
    @select_tags = {}
    @select_users = {}

    @tags.each do |tag|
      @select_tags = @select_tags.merge(tag.name => tag.id)
    end

    @users.each do |user|
      @select_users = @select_users.merge(user.name => user.id)
    end
  end

  def edit
    get_status
    @post = Post.find(params[:id])
    @select_tags = {}
    @new_tag_name = ""
    Tagging.search_post_taggings(params[:id]).each do |tagging|
      tag = Tag.find(:first,:conditions => ["id = ?",tagging.tag_id])
      @new_tag_name = @new_tag_name + "," unless @new_tag_name.blank?
      @new_tag_name = @new_tag_name + tag.name
    end
    @user = User.find(@post.user_id)
  end

  def create
    if params[:commit] == "Preview !"
      preview
      render :action => "new" and return
    end
    get_status
    save_post(Post.new)
    respond_to do |format|
      format.html { redirect_to @post, notice: 'Post was successfully created.' }
      format.json { render json: @post, status: :created, location: @post }
    end
  end

  def update
    if params[:commit] == "Preview !"
      preview
      @post.id = params[:post_id]

      render :action => "edit" and return
    end
    get_status
    post = Post.find(params[:post_id])
    save_post(post)
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    get_status
    @post = Post.find(params[:post_id])
    @post.destroy

    taggings = Tagging.where({:post_id => params[:post_id]})
    taggings.each do |tagging|
      tag = Tag.find(:first,:conditions => ["id =?",tagging.tag_id])
      tagging.destroy
      tag.destroy if Tagging.where({:tag_id => tag.id}).blank?
    end

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  def preview
    @body = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(params[:post][:body]).html_safe
    render
  end

  def search
    get_status
    @find_word = params[:find_word]
    @posts = Post.where("body like '%" + @find_word + "%'").order('created_at DESC').page(params[:page]).per(5)
    @labels = ["<span class=\"label\">","<span class=\"label label-success\">","<span class=\"label label-warning\">","<span class=\"label label-important\">","<span class=\"label label-info\">"]
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

  def preview
    get_status
    @post = Post.new
    @tag = Tag.new

    @post.id
    @post.title = params[:post][:title]
    @new_tag_name = params[:new_tag][:name]
    @post.body = params[:post][:body]

    @select_tags = {}
    @select_users = {}

    @tags.each do |tag|
      @select_tags = @select_tags.merge(tag.name => tag.id)
    end

    @users.each do |user|
      @select_users = @select_users.merge(user.name => user.id)
    end
    @preview = params[:post][:body]
  end

  def save_post(post)
    @post = post
    @post.title = params[:post][:title]
    @post.body = params[:post][:body]
    @post.user_id = session[:user_id]
    @post.save!

    # textfield
    if params[:new_tag][:name].index(",")
      new_tags = params[:new_tag][:name].split(",")
      new_tags.each do |tag_name|
        @tagging = Tagging.new
        tag = Tag.where(:name => tag_name).first
        if tag.blank?
          tag = Tag.new
          tag.name = tag_name
          tag.save!
        end
        @tagging.tag_id = tag.id
        @tagging.post_id = @post.id
        @tagging.save!
      end
    else
      @tagging = Tagging.new
      tag = Tag.where(:name => params[:new_tag][:name]).first
      if tag.blank?
        tag = Tag.new
        tag.name = params[:new_tag][:name]
        tag.save!
      end
      @tagging.tag_id = tag.id
      @tagging.post_id = @post.id
      @tagging.save!
    end
  end
end
