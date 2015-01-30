class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    get_status

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    get_status
    @tag = Tag.find(params[:id])
    taggings = Tagging.where(:tag_id => params[:id])

    post_ids = []
    taggings.each do |tagging|
      post_ids << tagging.post_id
    end
    post_ids.compact!

    @posts = Post.where(:id => post_ids).order('created_at DESC').page(params[:page]).per(5)
    @labels = ["<span class=\"label\">","<span class=\"label label-success\">","<span class=\"label label-warning\">","<span class=\"label label-important\">","<span class=\"label label-info\">"]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.json
  def new
    get_status
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    get_status
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.json
  def create
    get_status
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.json
  def update
    get_status
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    get_status
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to tags_url }
      format.json { head :no_content }
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
