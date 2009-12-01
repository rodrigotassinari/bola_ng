require 'digest/sha1'
class ScuttleService < Service

  # OK

  SERVICE_NAME = 'Scuttle'
  SERVICE_SLUG = 'scuttle'
  SERVICE_ICON = '/images/scuttle_favicon.png'

  SERVICE_ACTIONS = [Service::SERVICE_ACTION_BOOKMARK]

  validates_presence_of :scuttle_login, :icon_url

  settings_accessors([:scuttle_login])

  # returns an array of scuttle posts, newer posts first
  def fetch_entries
    entries = []
    doc = Hpricot.XML(open("http://links.pittlandia.net/rss/#{self.scuttle_login}"))
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
      :identifier => Digest::SHA1.hexdigest(entry[:link]),
      :title => entry[:title],
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => entry[:pubDate],
      :extra_content => {
        :original_tags => entry[:categories] # array de tags
      }
    )
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless self.scuttle_login.blank?
        self.profile_url = "http://links.pittlandia.net/bookmarks/#{self.scuttle_login}"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        :description => (entry/'description').inner_html,
        :categories => (entry/'category').map(&:inner_html)
      }
    rescue => e
      logger.warn "#{SERVICE_NAME}: Error parsing entry: #{e}"
      nil
    end

end
