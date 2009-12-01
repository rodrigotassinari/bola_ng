class LastfmService < Service

  # OK

  SERVICE_NAME = 'Last.fm'
  SERVICE_SLUG = 'lastfm'
  SERVICE_ICON = '/images/lastfm_favicon.ico'

  SERVICE_ACTIONS = [Service::SERVICE_ACTION_FAVE]

  validates_presence_of :lastfm_login, :icon_url

  settings_accessors([:lastfm_login])

  # returns an array of last.fm posts (faved tracks), newer posts first
  def fetch_entries
    entries = []
    doc = Hpricot.XML(open("http://ws.audioscrobbler.com/2.0/user/#{self.lastfm_login}/lovedtracks.rss"))
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
      :service_action => Service::SERVICE_ACTION_FAVE,
      :identifier => entry[:guid].split('#').last.to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate]
    )
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless self.lastfm_login.blank?
        #self.profile_url = "http://www.lastfm.com.br/user/#{self.lastfm_login}"
        self.profile_url = "http://last.fm/user/#{self.lastfm_login}"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html,
        :guid => (entry/'guid').inner_html
      }
    rescue => e
      logger.warn "#{SERVICE_NAME}: Error parsing entry: #{e}"
      nil
    end

end
