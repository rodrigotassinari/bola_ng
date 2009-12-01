class VisualizeusService < Service

  # OK

  SERVICE_NAME = 'Vi.sualize.us'
  SERVICE_SLUG = 'visualizeus'
  SERVICE_ICON = '/images/visualizeus_favicon.gif'

  SERVICE_ACTIONS = [Service::SERVICE_ACTION_BOOKMARK]

  validates_presence_of :visualizeus_login, :icon_url

  settings_accessors([:visualizeus_login])

  # returns an array of last.fm posts (faved tracks), newer posts first
  def fetch_entries
    entries = []
    doc = Hpricot.XML(open("http://vi.sualize.us/rss/#{self.visualizeus_login}/"))
    (doc/'item').each do |item|
      entries << parse_entry(item)
    end
    entries.reject { |e| e.nil? }
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
      :summary => entry[:description],
      :service_action => Service::SERVICE_ACTION_BOOKMARK,
      :identifier => entry[:guid].to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate],
      :extra_content => {
        :original_tags => entry[:tags],
        :image_url => entry[:image_url],
        :thumbnail_url => entry[:thumbnail_url],
        :medium_image_url => entry[:medium_image_url]
      }
    )
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless self.visualizeus_login.blank?
        self.profile_url = "http://vi.sualize.us/#{self.visualizeus_login}/"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html,
        :guid => (entry/'guid').inner_html.split(':').first,
        :tags => (entry/'guid').inner_html.split(':').last.split(',').map {|t| t.strip }, # array de tags
        :image_url => (entry/'media:content').first[:url],
        :thumbnail_url => (entry/'media:thumbnail').first[:url],
        :medium_image_url => (entry/'media:thumbnail').first[:url].gsub('_m.jpg', '_h.jpg')
      }
    rescue => e
      logger.warn "#{SERVICE_NAME}: Error parsing entry: #{e}"
      nil
    end

end
