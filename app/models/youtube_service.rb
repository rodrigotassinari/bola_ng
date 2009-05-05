class YoutubeService < Service

  # TODO não consegue data de favoritação, talvez tenha que passar pra rss

  SERVICE_NAME = 'YouTube'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :youtube_login, :icon_url

  settings_accessors([:youtube_login])

  # returns an array of youtube posts, newer posts first
  def fetch_entries(quantity=20)
    youtube = YouTubeG::Client.new
    youtube.logger = Rails.logger

    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent videos by #{self.youtube_login}"
    videos = youtube.videos_by(:user => self.youtube_login, :per_page => quantity)

    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent favorite videos of #{self.youtube_login}"
    likes = youtube.videos_by(:favorites, :user => self.youtube_login, :per_page => quantity)

    (videos.videos + likes.videos)
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
      :summary => entry.description,
      :service_action => (entry.author.name == self.youtube_login ? Service::SERVICE_ACTION_POST : Service::SERVICE_ACTION_FAVE),
      :identifier => entry.unique_id.to_s,
      :title => entry.title,
      :markup => Post::PLAIN_MARKUP,
      :url => entry.player_url,
      :published_at => entry.published_at, # FIXME como pegar a data da favoritação?
      :extra_content => {
        :original_tags => entry.keywords, # array de tags
        :user_name => entry.author.name
      }
    )
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts(quantity=20)
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
      unless self.youtube_login.blank?
        self.icon_url = "http://www.youtube.com/favicon.ico"
        self.profile_url = "http://www.youtube.com/user/#{self.youtube_login}"
      end
    end

end
