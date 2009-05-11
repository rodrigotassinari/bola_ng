class PostsController < ApplicationController
  before_filter :require_user, :except => [:show]
  before_filter :find_post

  # GET /posts/:id
  # Via: post_path(:id)
  # Avaiable: all
  #
  # Permalink for posts, redirects to the post's url.
  def show
    if @post.service.class == BlogService
      redirect_to blog_url(@post.slug)
    else
      redirect_to @post.url
    end
  end

  # GET /posts/:id/edit
  # Via: edit_post_path(:id)
  # Avaiable: logged_in
  #
  # Shows the edit form for the post.
  def edit
    @current_tab = 'lifestream'
    @page_title = "Lifestream :: Editando: #{@post.title}"
  end

  # PUT /posts/:id
  # Via: post_path(:id)
  # Avaiable: logged_in
  #
  # Updates the post.
  def update
    if @post.update_attributes(params[:post])
      flash[:success] = 'Post atualizado com sucesso'
      redirect_to lifestream_path(@post.service) # ???
    else
      render :action => :edit
    end
  end

  # DELETE /posts/:id
  # Via: post_path(:id)
  # Avaiable: logged_in
  #
  # Destroys the post.
  def destroy
    @post.destroy
    flash[:success] = 'Post apagado'
    redirect_to lifestream_index_path
  end

  protected

    def find_post
      @post = Post.with_service.find(params[:id])
    end

end
