class Post < ActiveRecord::Base

  HTML_MARKUP = 'html'
  PLAIN_MARKUP = 'plain'
  TEXTILE_MARKUP = 'textile'

  acts_as_taggable

  acts_as_textiled :body

  serialize :extra_content, Hash

  belongs_to :service

  cattr_reader :per_page
  @@per_page = 12

  validates_presence_of :service_id, :service_action, :identifier, :title, :summary, :url, :published_at
  validates_presence_of :body, :if => :is_article?
  validates_uniqueness_of :identifier, :scope => :service_id

  before_create :slugify_if_article
  #before_create :summarize_if_article # TODO
  before_create :taggify

  named_scope :published, 
    :conditions => '`posts`.`published_at` IS NOT NULL'
  named_scope :unpublished, 
    :conditions => '`posts`.`published_at` IS NULL'
  named_scope :ordered,
    :order => '`posts`.`published_at` DESC, `posts`.`updated_at` DESC, `posts`.`id` DESC'
  named_scope :latest,
    :limit => 5

  # returns true if this post is associated with a BlogService
  def is_article?
    self.service.class == BlogService
  end

  def to_param
    is_article? ? "#{self.id}-#{self.slug}" : "#{self.id}"
  end

  # returns true if there's already a post with the same service_id and
  # identifier, false otherwise.
  def exists?
    return true unless self.new_record?
    unless self.valid?
      if self.errors.on(:identifier) == I18n.t('activerecord.errors.messages.exclusion')
        true
      else
        false
      end
    else
      false
    end
  end

  protected

    def slugify_if_article
      if is_article?
        self.slug = PermalinkFu.escape(self.title)[0..60]
      end
    end

    def taggify
      if self.extra_content && 
          self.extra_content['original_tags'] &&
          self.tag_list.empty?
        self.tag_list = self.extra_content['original_tags'].
          map(&:downcase).
          join(', ').
          downcase
      end
    end

end
