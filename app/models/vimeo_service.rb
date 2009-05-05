class VimeoService < Service

  # TODO não consegue data de favoritação, talvez tenha que passar pra rss

  SERVICE_NAME = 'Vimeo'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :vimeo_login, :vimeo_user_id, :icon_url, :profile_image_url

  settings_accessors([:vimeo_login, :vimeo_user_id])

  # returns an array of vimeo posts, newer posts first
  def fetch_entries(quantity=15)
    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent videos by #{self.vimeo_login}"
    videos = Vimeo::Simple::User.clips(self.vimeo_login)

    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent favorite videos of #{self.vimeo_login}"
    likes = Vimeo::Simple::User.likes(self.vimeo_login)

    (videos + likes)
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      :summary => (entry['caption'].blank? ? '-' : entry['caption']),
      :service_action => (entry['user_name'] == self.vimeo_login ? Service::SERVICE_ACTION_POST : Service::SERVICE_ACTION_FAVE),
      :identifier => entry['clip_id'].to_s,
      :title => entry['title'],
      :markup => Post::PLAIN_MARKUP,
      :url => entry['url'],
      :published_at => entry['upload_date'].to_time, # FIXME como pegar a data da favoritação?
      :extra_content => {
        :thumbnail_small => entry['thumbnail_small'],
        :thumbnail_medium => entry['thumbnail_medium'],
        :thumbnail_large => entry['thumbnail_large'],
        :original_tags => entry['tags'].split(',').map {|t| t.strip }, # array de tags
        :user_name => entry['user_name'],
        :user_thumbnail => entry['user_thumbnail_small']
      }
    )
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts(quantity=15)
    entries = self.fetch_entries(quantity)
    posts = self.build_posts_from_entries(entries)
    posts.map do |post|
      if post.save
        post.id
      else
        logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages.to_sentence}"
        nil
      end
    end
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless self.vimeo_login.blank?
        user_info = Vimeo::Simple::User.info(self.vimeo_login)
        self.icon_url = "http://vimeo.com/favicon.ico"
        self.profile_url = user_info['profile_url']
        self.profile_image_url = user_info['thumbnail_small']
        self.vimeo_user_id = user_info['id']
      end
    end

end
