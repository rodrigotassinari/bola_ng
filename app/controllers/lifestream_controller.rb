class LifestreamController < ApplicationController

  # GET /
  # GET /lifestream
  # Via: root_path
  # Via: lifestream_index_path
  # Avaiable: all
  #
  # Shows the combined lifestream.
  def index
    respond_to do |format|
      
      format.html do
        @current_tab = 'lifestream'
        @page_title = "Lifestream"
        @feed_url = lifestream_index_url(:format => :rss)

        @posts = if current_user
          Post.ordered.with_service.paginate(:page => params[:page])
        else
          Post.published.ordered.with_service.paginate(:page => params[:page])
        end
      end

      format.rss do
        @posts = Post.published.ordered.with_service.paginate(:page => params[:page], :per_page => 25)
      end

    end
  end

  # GET /lifestream/:id
  # Via: lifestream_path(:id)
  # Avaiable: all
  #
  # Shows the lifestream of the supplied feed only.
  def show
    @service = Service.find_by_slug(params[:id])
    
    unless @service.class == BlogService

      respond_to do |format|

        format.html do
          @current_tab = 'lifestream'
          @posts = if current_user
            @service.posts.ordered.with_service.paginate(:page => params[:page])
          else
            @service.posts.published.ordered.with_service.paginate(:page => params[:page])
          end
          @page_title = "Lifestream :: #{@service.name}"
          @feed_url = lifestream_url(@service, :format => :rss)
        end

        format.rss do
          @posts = @service.posts.published.ordered.with_service.paginate(:page => params[:page], :per_page => 25)
        end

      end
      
    else
      redirect_to blog_index_path
    end
  end

end
