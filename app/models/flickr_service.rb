class FlickrService < Service

  # TODO muito lento, transformar pra buscar via rss se conseguir as tags

  SERVICE_NAME = 'Flickr'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST, Service::SERVICE_ACTION_FAVE]

  validates_presence_of :flickr_api_key, :flickr_email, :icon_url

  settings_accessors([:flickr_api_key, :flickr_email, :flickr_user_id])

  # returns an array of flickr posts, newer posts first
  def fetch_entries(quantity=15)
    user = self.flickr_user!

    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent photos by #{user.id}"
    user_photos = user.photos(:per_page => quantity)

    logger.info "#{SERVICE_NAME}: Fetching the #{quantity} most recent favorite photos of #{user.id}"
    user_favorites = user.favorites[0..(quantity-1)] # temporário
    #user_favorites = user.favorites(:per_page => quantity) # FIXME esperar atualização da gem que permitirá isso

    (user_photos + user_favorites)
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  # TODO tentar novamente x vezes em caso de erro, com y segundos de intervalo entre as tentativas
  def build_post_from_entry(entry)
    Timeout.timeout 5 do
      logger.info "#{SERVICE_NAME}: Loading extra info about photo #{entry.id}"
      entry.description # pra forçar o getInfo logo
    end
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
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching extra info about photo #{entry.id} (timeout error): #{tme}"
    self.posts.build
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

    # returns a new Flickr object using this service's api key
    def flickr_client
      Flickr.new(self.flickr_api_key)
    end

    # returns a new Flickr::User object using this service's api key and flickr
    # email -- returns the flickr user associated with this service.
    #
    # raiser exception in case of error.
    def flickr_user!
      logger.info "#{SERVICE_NAME}: Loading the flickr user for #{self.flickr_email}"
      client = self.flickr_client
      client.users(self.flickr_email)
    end

    # returns a new Flickr::User object using this service's api key and flickr
    # email -- returns the flickr user associated with this service.
    #
    # returns +nil+ in case of failure.
    def flickr_user
      self.flickr_user!
    rescue
      nil
    end

    # before_validation_on_create
    def set_url_attributes
      unless self.flickr_api_key.blank? && self.flickr_email.blank?
        if self.flickr_user
          self.icon_url = "http://www.flickr.com/favicon.ico"
          self.profile_url = self.flickr_user.pretty_url
          self.flickr_user_id = self.flickr_user.id
        end
      end
    end

end
