class YoutubeService < Service

  # OK

  SERVICE_NAME = 'YouTube'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :youtube_login, :icon_url

  settings_accessors([:youtube_login])

  # returns an array of youtube posts, newer posts first
  def fetch_entries(quantity=20)
    logger.info "#{SERVICE_NAME}: Fetching the most recent videos by #{self.youtube_login}"
    videos = []
    doc = Hpricot.XML(open("http://gdata.youtube.com/feeds/api/users/#{self.youtube_login}/uploads"))
    (doc/'entry').each do |item|
      videos << parse_entry(item)
    end

    logger.info "#{SERVICE_NAME}: Fetching the most recent favorite videos of #{self.youtube_login}"
    likes = []
    doc = Hpricot.XML(open("http://gdata.youtube.com/feeds/api/users/#{self.youtube_login}/favorites"))
    (doc/'entry').each do |item|
      likes << parse_entry(item)
    end

    return videos, likes
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry, action)
    self.posts.build(
      :summary => (entry[:content].blank? ? '-' : entry[:content]),
      :service_action => action,
      :identifier => entry[:guid],
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => (action == Service::SERVICE_ACTION_POST ? entry[:published] : Time.current),
      :extra_content => {
        :original_tags => entry[:keywords] # array de tags
      }
    )
  end

  def build_posts_from_entries(entries, action)
    entries.map { |entry| self.build_post_from_entry(entry, action) }
  end

  def create_posts
    videos, likes = self.fetch_entries
    videos_posts = self.build_posts_from_entries(videos, Service::SERVICE_ACTION_POST)
    liked_posts = self.build_posts_from_entries(likes, Service::SERVICE_ACTION_FAVE)
    (videos_posts + liked_posts).map do |post|
      unless post.exists?
        if post.save
          post.id
        else
          logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages.to_sentence}"
          nil
        end
      else
        logger.info "Post: #{post.service.try(:name)} - #{post.identifier} -- already exists."
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

    def parse_entry(entry)
      {
        :guid => (entry/'id').inner_html.split('/').last,
        :title => (entry/'title').inner_html,
        :published => (entry/'published').inner_html.to_time,
        :updated => (entry/'updated').inner_html.to_time,
        :content => (entry/'content').inner_html,
        :keywords => (entry/'media:keywords').inner_html.split(',').map(&:strip),
        :link => (entry/"link[@rel='alternate']").first['href']
      }
    end

end
