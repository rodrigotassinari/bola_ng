class AddSlugToService < ActiveRecord::Migration
  def self.up
    add_column :services, :slug, :string
  end

  def self.down
    remove_column :services, :slug
  end
end
