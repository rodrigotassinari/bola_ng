class GoogleReaderService < Service

  # OK

  SERVICE_NAME = 'Google Reader'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_SHARE]

  validates_presence_of :google_reader_url, :google_reader_feed_url

  settings_accessors([:google_reader_url, :google_reader_feed_url])

  # returns an array of google reader shared posts, newer posts first
  def fetch_entries(quantity=15)
    entries = []
    doc = Hpricot.XML(open(self.google_reader_feed_url))
    (doc/'entry').each do |item|
      entries << parse_entry(item)
    end
    entries[0..quantity-1]
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
      :summary => (entry[:summary].blank? ? '-' : entry[:summary]),
      :service_action => Service::SERVICE_ACTION_SHARE,
      :identifier => entry[:guid].to_s,
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:published],
      :extra_content => {
        :original_guid => entry[:original_guid],
        :updated => entry[:updated],
        :original_tags => entry[:categories] # array de tags
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
      unless self.google_reader_url.blank?
        self.icon_url = 'http://www.google.com/reader/ui/favicon.ico'
        self.profile_url = self.google_reader_url
      end
    end

    def parse_entry(entry)
      {
        :guid => (entry/'id').first.inner_html,
        :original_guid => (entry/'id').first['gr:original-id'],
        :categories => (entry/'category').map { |e| e['term'] },
        :title => (entry/'title').first.inner_html,
        :link => (entry/'link').first['href'],
        :published => (entry/'published').inner_html.to_time,
        :updated => (entry/'updated').inner_html.to_time,
        :summary => (entry/'summary').inner_html
      }
    end

end
