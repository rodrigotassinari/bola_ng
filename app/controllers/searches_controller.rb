class SearchesController < ApplicationController

  # GET /search?q=blabla
  # Via: search_path(:q => 'blabla')
  # Avaiable: all
  #
  # Shows the combined lifestream with posts that match the query.
  def show
    @query = params[:q]
    respond_to do |format|
      format.html do
        @current_tab = 'lifestream'
        @page_title = "Lifestream :: Busca :: #{@query}"
        @feed_url = search_url(:q => @query,:format => :rss)
        @posts = if current_user
          Post.ordered.with_service.search_for(@query).paginate(:page => params[:page])
        else
          Post.published.ordered.with_service.search_for(@query).paginate(:page => params[:page])
        end
      end
      format.rss do
        @posts = Post.published.ordered.with_service.search_for(@query).paginate(:page => params[:page], :per_page => 25)
      end
    end
  end

end
