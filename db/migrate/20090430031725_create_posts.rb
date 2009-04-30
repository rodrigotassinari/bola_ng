class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer  :service_id
      t.string   :service_action
      t.string   :identifier
      t.string   :title
      t.string   :slug
      t.string   :markup
      t.text     :body
      t.text     :summary
      t.text     :extra_content
      t.string   :url
      t.string   :cached_tag_list
      t.datetime :published_at

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
