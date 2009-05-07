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
    @current_tab = 'lifestream'

    @tag = Tag.find_by_name(params[:name]) || Tag.find_by_name(params[:id])
    raise ActiveRecord::RecordNotFound,
      "Couldn't find Tag with name = #{params[:name] || params[:id]}" if @tag.nil?

    @posts = Post.published.ordered.with_service.paged_find_tagged_with(
      @tag.name,
      :page => params[:page]
    )
    @page_title = "Lifestream :: Tags :: #{@tag.name}"
  end

end
