class FlickrService < Service

  SERVICE_NAME = 'Flickr'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :flickr_api_key, :flickr_email, :icon_url

  settings_accessors([:flickr_api_key, :flickr_email, :flickr_user_id])

  # returns an array of flickr posts, newer posts first
  def fetch_entries(quantity=15)
    user = self.flickr_user!

    user_photos = user.photos(:per_page => quantity)

    user_favorites = user.favorites[0..(quantity-1)] # temporário
    #user_favorites = user.favorites(:per_page => quantity) # TODO esperar atualização da gem que permitirá isso

    (user_photos + user_favorites)
  rescue => e
    logger.warn "Error fetching posts from #{SERVICE_NAME}: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      :body => entry.description, # primeiro pra forçar o getInfo logo
      :service_action => (entry.owner.id == self.flickr_user_id ? Service::SERVICE_ACTION_POST : Service::SERVICE_ACTION_FAVE),
      :identifier => entry.id.to_s,
      :title => entry.title,
      :markup => Post::PLAIN_MARKUP,
      :url => entry.pretty_url,
      :published_at => Time.at(entry['dates']['posted'].to_i),
      :extra_content => {
        :image_url_square => entry.source(:square),
        :image_url_thumbnail => entry.source(:thumbnail),
        :image_url_small => entry.source(:small),
        :image_url_medium => entry.source(:medium),
        :image_url_large => entry.source(:large),
        :image_url_original => entry.source(:original)
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
        logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages}"
        nil
      end
    end
  end

  protected

    # returns a new Flickr object using this service's api key
    def flickr_client
      Flickr.new(self.flickr_api_key)
    end

    # returns a new Flickr::User object using this service's api key and flickr
    # email -- returns the flickr user associated with this service.
    #
    # raiser exception in case of error.
    def flickr_user!
      client = self.flickr_client
      client.users(self.flickr_email)
    end

    # returns a new Flickr::User object using this service's api key and flickr
    # email -- returns the flickr user associated with this service.
    #
    # returns +nil+ in case of failure.
    def flickr_user
      self.flick_user!
    rescue
      nil
    end

    # before_validation_on_create
    def set_url_attributes
      unless flickr_api_key.blank? && flickr_email.blank?
        if self.flickr_user
          self.icon_url = "http://www.flickr.com/favicon.ico"
          self.profile_url = flickr_user.pretty_url
          self.flickr_user_id = flickr_user.id
        end
      end
    end

end
