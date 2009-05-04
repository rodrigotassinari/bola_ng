require 'digest/sha1'
class WordpressService < Service

  # OK

  SERVICE_NAME = 'Wordpress Blog' # changed by the user
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST]

  validates_presence_of :wordpress_url, :wordpress_name, :wordpress_feed_url

  settings_accessors([:wordpress_url, :wordpress_name, :wordpress_favicon_url, :wordpress_feed_url])

  # returns an array of wordpress posts, newer posts first
  def fetch_entries(quantity=15)
    entries = []
    doc = Hpricot.XML(open(self.wordpress_feed_url))
    (doc/'item').each do |item|
      entries << parse_entry(item)
    end
    entries[0..quantity-1]
  rescue Timeout::Error => tme
    logger.warn "#{self.name}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{self.name}: Error fetching posts: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      :summary => entry[:description],
      :service_action => Service::SERVICE_ACTION_POST,
      :identifier => Digest::SHA1.hexdigest(entry[:guid]),
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate],
      :extra_content => {
        :body_encoded => entry[:description_encoded],
        :original_url => entry[:original_link],
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
      unless self.wordpress_url.blank? && self.wordpress_name.blank?
        self.name = self.wordpress_name
        self.icon_url = self.wordpress_favicon_url
        self.profile_url = self.wordpress_url
      end
    end

    def parse_entry(entry)
      {
        :guid => (entry/'guid').inner_html,
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html.gsub(/\A\<\!\[CDATA\[/, '').gsub(/\]\]\>\Z/, ''),
        :categories => (entry/'category').map(&:inner_html).map { |t| t.gsub(/\A\<\!\[CDATA\[/, '').gsub(/\]\]\>\Z/, '') },
        :original_link => (entry/'feedburner:origLink').inner_html,
        :description_encoded => (entry/'content:encoded').inner_html.gsub(/\A\<\!\[CDATA\[/, '').gsub(/\]\]\>\Z/, '')
      }
    end

end
