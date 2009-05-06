class VimeoService < Service

  # OK

  SERVICE_NAME = 'Vimeo'
  SERVICE_SLUG = 'vimeo'
  SERVICE_ICON = '/images/vimeo_favicon.ico'

  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :vimeo_login, :icon_url

  settings_accessors([:vimeo_login])

  # returns an array of vimeo posts, newer posts first
  def fetch_entries
    logger.info "#{SERVICE_NAME}: Fetching the most recent videos by #{self.vimeo_login}"
    videos = []
    doc = Hpricot.XML(open("http://vimeo.com/#{self.vimeo_login}/videos/rss"))
    (doc/'item').each do |item|
      videos << parse_entry(item)
    end

    logger.info "#{SERVICE_NAME}: Fetching the most recent favorite videos of #{self.vimeo_login}"
    likes = []
    doc = Hpricot.XML(open("http://vimeo.com/#{self.vimeo_login}/likes/rss"))
    (doc/'item').each do |item|
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
      :summary => (entry[:description].blank? ? '-' : entry[:description]),
      :service_action => action,
      :identifier => entry[:guid].to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => (action == Service::SERVICE_ACTION_POST ? entry[:pubDate] : Time.current),
      :extra_content => {
        :author_name => entry[:author_name],
        :original_tags => entry[:categories] # array de tags
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
      unless self.vimeo_login.blank?
        self.profile_url = "http://vimeo.com/#{self.vimeo_login}"
      end
    end

    def parse_entry(entry)
      {
        :guid => (entry/'link').inner_html.split('/').last,
        :title => (entry/'title').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :categories => (entry/"media:category[@label='Tags']").inner_text.try(:split, ',').try(:map, &:strip),
        :link => (entry/'link').inner_html,
        :description => (entry/'description').first.inner_text,
        :author_name => (entry/'dc:creator').first.inner_html
      }
    end

end
