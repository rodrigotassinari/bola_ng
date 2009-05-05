class DeliciousService < Service

  # OK

  SERVICE_NAME = 'Delicious'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_BOOKMARK]

  validates_presence_of :delicious_login, :icon_url

  settings_accessors([:delicious_login])

  # returns an array of delicious posts, newer posts first
  def fetch_entries(quantity=30)
    entries = []
    doc = Hpricot.XML(open("http://feeds.delicious.com/v2/rss/#{self.delicious_login}?count=#{quantity}"))
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
      :summary => (entry[:description].blank? ? '-' : entry[:description]),
      :service_action => Service::SERVICE_ACTION_BOOKMARK,
      :identifier => entry[:guid].to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate],
      :extra_content => {
        :original_tags => entry[:categories] # array de tags
      }
    )
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts
    entries = self.fetch_entries
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
      unless self.delicious_login.blank?
        self.icon_url = "http://delicious.com/favicon.ico"
        self.profile_url = "http://delicious.com/#{self.delicious_login}"
      end
    end

    def parse_entry(entry)
      {
        :guid => (entry/'guid').inner_html.split('/').last,
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html,
        :categories => (entry/'category').map(&:inner_html)
      }
    end

end
