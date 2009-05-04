class BlogService < Service

  SERVICE_NAME = 'Blog'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST]

  validates_presence_of :blog_url # http://server/blog

  settings_accessors([:blog_url])

  protected

    # before_validation_on_create
    def set_url_attributes
      self.profile_url = self.blog_url
    end

end
