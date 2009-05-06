class Service < ActiveRecord::Base

  SERVICE_NAME = nil
  SERVICE_SLUG = nil
  SERVICE_ACTION_POST = 'posted'
  SERVICE_ACTION_FAVE = 'faved'
  SERVICE_ACTION_SHARE = 'shared'
  SERVICE_ACTION_BOOKMARK = 'bookmarked'

  has_many :posts

  serialize :settings, Hash

  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}
  named_scope :fetchable, :conditions => ["`services`.`type` <> ?", 'BlogService']

  validates_presence_of :type, :name, :slug, :profile_url
  validates_uniqueness_of :name, :slug, :profile_url

  def after_initialize
    if self.new_record?
      self.name = self.class::SERVICE_NAME
      self.slug = self.class::SERVICE_SLUG
    end
  end

  before_validation_on_create :set_url_attributes

  def to_param
    self.slug
  end

  # Creates virtual attributes that are accessors (getters and setters) to the
  # keys in the settings hash.
  def self.settings_accessors(fields)
    [fields].flatten.each do |attr_name|
      methods = <<-EOF
        def #{attr_name}
          self.settings ||= {}
          self.settings[:#{attr_name}]
        end
        def #{attr_name}=(new_#{attr_name})
          self.settings ||= {}
          self.settings[:#{attr_name}] = new_#{attr_name}
        end
        def #{attr_name}_before_type_cast
          self.#{attr_name}
        end
      EOF
      eval(methods)
    end
  end
  
  def fetch_entries(quantity=15)
    # overwrite in the child services
  end
  
  def build_post_from_entry(entry)
    # overwrite in the child services
  end

  def build_posts_from_entries(entries)
    entries.map { |entry| self.build_post_from_entry(entry) }
  end

  def create_posts
    entries = self.fetch_entries
    posts = self.build_posts_from_entries(entries)
    posts.map do |post|
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

  # fetches entries and creates posts for all active services (except
  # BlogService's)
  def self.create_posts
    services = self.active.fetchable.all
    services.each do |service|
      service.create_posts # TODO rodar assíncronamente e atômicamente
    end
  end

  protected

    def set_url_attributes
      # overwrite in the child services
    end

end
