class FlickrService < Service

  # OK

  SERVICE_NAME = 'Flickr'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :flickr_user_name, :flickr_user_id, :flickr_author_profile_url, :icon_url

  settings_accessors([:flickr_user_name, :flickr_user_id, :flickr_author_profile_url])

  # returns an array of delicious posts, newer posts first
  def fetch_entries
    logger.info "#{SERVICE_NAME}: Fetching the most recent photos by #{self.flickr_user_name}"
    photo_entries = []
    doc = Hpricot.XML(open("http://api.flickr.com/services/feeds/photos_public.gne?id=#{self.flickr_user_id}&lang=en-us&format=rss_200"))
    (doc/'item').each do |item|
      photo_entries << parse_entry(item)
    end
    
    logger.info "#{SERVICE_NAME}: Fetching the most recent favorite photos of #{self.flickr_user_name}"
    faved_entries = []
    doc = Hpricot.XML(open("http://api.flickr.com/services/feeds/photos_faves.gne?nsid=#{self.flickr_user_id}&lang=en-us&format=rss_200"))
    (doc/'item').each do |item|
      faved_entries << parse_entry(item)
    end

    return photo_entries, faved_entries
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    return [], []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e.backtrace}"
    return [], []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry, action)
    self.posts.build(
      :summary => entry[:description],
      :service_action => action,
      :identifier => entry[:guid].to_s,
      :title => (entry[:title].blank? ? '-' : entry[:title]),
      :markup => Post::PLAIN_MARKUP,
      :url => entry[:link],
      :published_at => (action == Service::SERVICE_ACTION_POST ? entry[:pubDate] : Time.current),
      :extra_content => {
        :image_url_square => entry[:image_url_square],
        :image_url_thumbnail => entry[:image_url_thumbnail],
        :image_url_small => entry[:image_url_small],
        :image_url_medium => entry[:image_url_medium],
        :image_url_large => entry[:image_url_large],
        :image_url_original => entry[:image_url_original],
        :author_name => entry[:author_name],
        :author_profile_url => entry[:author_profile_url],
        :original_tags => entry[:categories] # array de tags
      }
    )
  end

  def build_posts_from_entries(entries, action)
    entries.map { |entry| self.build_post_from_entry(entry, action) }
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts
    photos, faved = self.fetch_entries
    photo_posts = self.build_posts_from_entries(photos, Service::SERVICE_ACTION_POST)
    faved_posts = self.build_posts_from_entries(faved, Service::SERVICE_ACTION_FAVE)
    (photo_posts + faved_posts).map do |post|
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
      unless self.flickr_user_id.blank? && self.flickr_user_name.blank?
        self.icon_url = "http://www.flickr.com/favicon.ico"
        self.profile_url = "http://www.flickr.com/photos/#{self.flickr_user_name}/"
        self.flickr_author_profile_url = "http://www.flickr.com/people/#{self.flickr_user_name}/"
      end
    end

    def parse_entry(entry)
      {
        :title => (entry/'title').inner_html,
        :link => (entry/'link').inner_html,
        :description => (entry/'description').inner_html,
        :pubDate => (entry/'pubDate').inner_html.to_time,
        #:date_taken => ( (entry/'dc:date.Taken').inner_html.nil? ? nil : (entry/'dc:date.Taken').inner_html.to_time ), # FIXME
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
