class LastfmService < Service

  SERVICE_NAME = 'Last.fm'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_FAVE]

  validates_presence_of :lastfm_login, :icon_url

  settings_accessors([:lastfm_login])

  # returns an array of last.fm posts (faved tracks), newer posts first
  def fetch_entries(quantity=15)
    entries = []
    doc = Hpricot.XML(open("http://ws.audioscrobbler.com/2.0/user/#{self.lastfm_login}/lovedtracks.rss"))
    (doc/'item').each do |item|
      entries << parse_entry(item)
    end
    entries[0..quantity]
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
      :body => entry[:description],
      :service_action => Service::SERVICE_ACTION_FAVE,
      :identifier => entry[:guid].split('#').last.to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate]
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
      unless self.lastfm_login.blank?
        self.icon_url = "http://cdn.last.fm/flatness/favicon.2.ico"
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
    end

end
