class Post < ActiveRecord::Base

  HTML_MARKUP = 'html'
  PLAIN_MARKUP = 'plain'
  TEXTILE_MARKUP = 'textile'

  acts_as_taggable

  serialize :extra_content, Hash

  belongs_to :service

  cattr_reader :per_page
  @@per_page = 12

  validates_presence_of :service_id, :service_action, :identifier, :title, :url, :published_at
  validates_uniqueness_of :identifier, :scope => :service_id

  #before_create :slugify_if_article # TODO

end
