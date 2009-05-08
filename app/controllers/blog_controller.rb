class BlogController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_service
  
  # GET /blog
  # Via: blog_index_path
  # Avaiable: all
  #
  # Shows all blog posts.
  def index
    @current_tab = 'blog'
    @page_title = "Blog"
    
    @posts = if current_user
      @service.posts.ordered.with_service.paginate(:page => params[:page])
    else
      @service.posts.published.ordered.with_service.paginate(:page => params[:page])
    end
  end

  # GET /blog/:id
  # Via: blog_path(:slug) ou blog_path(:id)
  # Avaiable: all
  #
  # Shows one blog post.
  def show
    @current_tab = 'blog'

    @post = @service.posts.published.ordered.with_service.find_by_slug(params[:id]) || @service.posts.published.ordered.with_service.find(params[:id])
    @post_context = @post.context
    @page_title = "Blog :: #{@post.title}"
  end

  # GET /blog/new
  # Via: new_blog_path
  # Avaiable: logged_in
  #
  # Shows the form to create a new blog post.
  def new
    @current_tab = 'blog'
    @page_title = "Blog :: Novo"
    @post = @service.build
  end

  # POST /blog
  # Via: blog_index_path
  # Avaiable: logged_in
  #
  # Creates a new blog post.
  def create
    # TODO
  end

  # GET /blog/:id/edit
  # Via: edit_blog_path(:id)
  # Avaiable: logged_in
  #
  # Shows the form to edit a blog post.
  def edit
    @current_tab = 'blog'
    @post = @service.posts.find(params[:id])
    @page_title = "Blog :: Editando: #{@post.title}"
  end

  # PUT /blog/:id
  # Via: blog_path(:id)
  # Avaiable: logged_in
  #
  # Updates the blog post.
  def update
    # TODO
  end

  # DELETE /blog/:id
  # Via: blog_path(:id)
  # Avaiable: logged_in
  #
  # Destroys the blog post.
  def destroy
    # TODO
  end

  protected

    def find_service
      @service = BlogService.active.first
    end
  
end
