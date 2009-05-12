class AddPublishedBooleanToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :published, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :posts, :published
  end
end
