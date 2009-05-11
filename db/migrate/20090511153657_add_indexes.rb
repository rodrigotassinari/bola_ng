class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :slug
    add_index :posts, [:service_id, :identifier]
    add_index :posts, :published_at

    add_index :services, :slug
  end

  def self.down
    remove_index :posts, :slug
    remove_index :posts, [:service_id, :identifier]
    remove_index :posts, :published_at

    remove_index :services, :slug
  end
end
