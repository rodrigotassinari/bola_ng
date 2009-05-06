class BlipfmService < Service

  # OK

  SERVICE_NAME = 'Blip.fm'
  SERVICE_SLUG = 'blipfm'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST]

  validates_presence_of :blipfm_login, :icon_url

  settings_accessors([:blipfm_login])

  # returns an array of last.fm posts (faved tracks), newer posts first
  def fetch_entries
    entries = []
    doc = Hpricot.XML(open("http://blip.fm/feed/#{self.blipfm_login}"))
    (doc/'item').each do |item|
      entries << parse_entry(item)
    end
    entries
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
      :service_action => Service::SERVICE_ACTION_POST,
      :identifier => entry[:guid].to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate]
    )
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless self.blipfm_login.blank?
        self.icon_url = "http://blip.fm/favicon.ico"
        self.profile_url = "http://blip.fm/#{self.blipfm_login}"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html.gsub(/\A\<\!\[CDATA\[/, '').gsub(/\]\]\>\Z/, '').chomp,
        :link => (entry/'link').inner_html.chomp,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html.gsub(/\A\<\!\[CDATA\[/, '').gsub(/\]\]\>\Z/, '').chomp,
        :guid => (entry/'guid').inner_html.split('/').last.chomp
      }
    end

end
