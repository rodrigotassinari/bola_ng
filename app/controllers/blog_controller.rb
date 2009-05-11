class BlogController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_service
  
  # GET /blog
  # Via: blog_index_path
  # Avaiable: all
  #
  # Shows all blog posts.
  def index
    respond_to do |format|

      format.html do
        @current_tab = 'blog'
        @page_title = "Blog"
        @feed_url = blog_index_url(:format => :rss)

        @posts = if current_user
          @service.posts.ordered.with_service.paginate(:page => params[:page])
        else
          @service.posts.published.ordered.with_service.paginate(:page => params[:page])
        end
      end

      format.rss do
        @posts = @service.posts.published.ordered.with_service.paginate(:page => params[:page], :per_page => 25)
      end

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
    @post = @service.posts.build
  end

  # POST /blog
  # Via: blog_index_path
  # Avaiable: logged_in
  #
  # Creates a new blog post.
  def create
    @post = @service.posts.build(params[:post])
    if @post.save
      flash[:success] = 'Post criado com sucesso'
      redirect_to blog_path(@post.slug)
    else
      render :action => :new
    end
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
    @post = @service.posts.find(params[:id])
    if @post.update_attributes(params[:post])
      flash[:success] = 'Post atualizado com sucesso'
      redirect_to blog_path(@post.slug)
    else
      render :action => :edit
    end
  end

  # DELETE /blog/:id
  # Via: blog_path(:id)
  # Avaiable: logged_in
  #
  # Destroys the blog post.
  def destroy
    @post = @service.posts.find(params[:id])
    @post.destroy
    flash[:success] = 'Post apagado'
    redirect_to blog_index_path
  end

  protected

    def find_service
      @service = BlogService.active.first
    end
  
end
