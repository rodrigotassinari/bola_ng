class TagsController < ApplicationController

  # GET /tags
  # Via: tags_path
  # Avaiable: all
  #
  # Shows a cloud of all tags.
  def index
    @current_tab = 'lifestream'
    @page_title = "Lifestream :: Tags"
    @tags = Post.tag_counts(:order => 'count desc')
  end

  # GET /tags/:id
  # Via: tag_path(:id)
  # Avaiable: all
  #
  # Shows all feed_items related to the supplied tag (by name).
  def show
    @tag = Tag.find_by_name(params[:name]) || Tag.find_by_name(params[:id])
    raise ActiveRecord::RecordNotFound,
      "Couldn't find Tag with name = #{params[:name] || params[:id]}" if @tag.nil?

    respond_to do |format|
      
      format.html do
        @posts = Post.published.ordered.with_service.paged_find_tagged_with(
          @tag.name,
          :page => params[:page]
        )
        @current_tab = 'lifestream'
        @page_title = "Lifestream :: Tags :: #{@tag.name}"
        @feed_url = tag_name_url(@tag.name, :format => :rss)
      end
      
      format.rss do
        @posts = Post.published.ordered.with_service.paged_find_tagged_with(
          @tag.name,
          :page => params[:page],
          :per_page => 25
        )
      end
      
    end
  end

end
