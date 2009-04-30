class FlickrService < Service

  SERVICE_NAME = 'Flickr'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :flickr_api_key, :flickr_email, :icon_url

  settings_accessors([:flickr_api_key, :flickr_email, :flickr_user_id]) # 'a5ff1ce4ae9c21c47b668530703ebda4', 'rodrigo@pittlandia.net'

  # returns an array of flickr posts, newer posts first
  def fetch_entries(quantity=15)
    # TODO
  rescue => e
    logger.warn "Error fetching posts from #{SERVICE_NAME}: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      # TODO
    )
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts
    # TODO
    entries = self.fetch_entries
    posts = self.build_posts_from_entries(entries)
    posts.map do |post|
      if post.save
        post.id
      else
        logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages}"
        nil
      end
    end
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless flickr_api_key.blank? && flickr_email.blank?
        flickr_user = fetch_flickr_user
        if flickr_user
          self.icon_url = "http://www.flickr.com/favicon.ico"
          self.profile_url = flickr_user.pretty_url
          self.flickr_user_id = flickr_user.id
        end
      end
    end

    # returns a Flickr::User object
    def fetch_flickr_user
      return if flickr_api_key.blank?
      return if flickr_email.blank?
      flickr = Flickr.new(flickr_api_key)
      flickr.users(flickr_email)
    rescue
      nil
    end

end
