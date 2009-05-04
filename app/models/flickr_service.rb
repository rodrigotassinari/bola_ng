class FlickrService < Service

  # DOING! BROKEN!
  # como saber se é post ou faved ao criar post?
  # pedir nome e buscar id via webapp?
  # buscar por "var photostream_owner_nsid = "51201321@N00";" em http://www.flickr.com/photos/userid/ ?

  SERVICE_NAME = 'Flickr'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :flickr_user_name, :flickr_user_id, :icon_url

  settings_accessors([:flickr_user_name, :flickr_user_id])

  # returns an array of delicious posts, newer posts first
  def fetch_entries(quantity=15)
    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent photos by #{self.flickr_user_id}"
    photo_entries = []
    doc = Hpricot.XML(open("http://api.flickr.com/services/feeds/photos_public.gne?id=#{self.flickr_user_id}&lang=en-us&format=rss_200"))
    (doc/'item').each do |item|
      photo_entries << parse_entry(item)
    end
    
    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent favorite photos of #{self.flickr_user_id}"
    faved_entries = []
    doc = Hpricot.XML(open("http://api.flickr.com/services/feeds/photos_faves.gne?nsid=#{self.flickr_user_id}&lang=en-us&format=rss_200"))
    (doc/'item').each do |item|
      faved_entries << parse_entry(item)
    end

    (photo_entries[0..quantity-1] + faved_entries[0..quantity-1])
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e.backtrace}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      :summary => entry.description,
      :service_action => (entry.owner.id == self.flickr_user_id ? Service::SERVICE_ACTION_POST : Service::SERVICE_ACTION_FAVE),
      :identifier => entry.id.to_s,
      :title => (entry.title || '-'),
      :markup => Post::PLAIN_MARKUP,
      :url => entry.pretty_url,
      :published_at => (entry.owner.id == self.flickr_user_id ? Time.at(entry['dates']['posted'].to_i) : Time.at(entry['date_faved'].to_i)),
      :extra_content => {
        :image_url_square => entry.source(:square),
        :image_url_thumbnail => entry.source(:thumbnail),
        :image_url_small => entry.source(:small),
        :image_url_medium => entry.source(:medium),
        :image_url_large => entry.source(:large),
        :image_url_original => entry.source(:original),
        :original_tags => entry.tags.blank? ? [] : entry.tags['tag'].map { |t| t['raw'] } # array de tags
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
      unless self.flickr_user_id.blank? && self.flickr_user_name.blank?
        self.icon_url = "http://www.flickr.com/favicon.ico"
        self.profile_url = "http://www.flickr.com/photos/#{self.flickr_user_name}/"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :description => (entry/'description').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        #:date_taken => ( (entry/'dc:date.Taken').inner_html.nil? ? nil : (entry/'dc:date.Taken').inner_html.to_time ),
        :author_name => (entry/'author').first.inner_html.gsub(/\Anobody\@flickr\.com \(/, '').gsub(/\)\Z/, ''),
        :author_profile_url => (entry/'author').first['flickr:profile'],
        :guid => (entry/'guid').inner_html.split(':').last.split('/').last,
        :image_url_square => (entry/'media:thumbnail').first['url'],
        :image_url_thumbnail => (entry/'media:thumbnail').first['url'].gsub(/\_s\./, '_t.'),
        :image_url_small => (entry/'media:thumbnail').first['url'].gsub(/\_s\./, '_m.'),
        :image_url_medium => (entry/'media:thumbnail').first['url'].gsub(/\_s\./, '.'),
        :image_url_large => (entry/'media:thumbnail').first['url'].gsub(/\_s\./, '_b.'),
        :image_url_original => (entry/'media:content').first['url'],
        :categories => (entry/'media:category').first.try(:inner_html).try(:split, ' ')
      }
    end

end
