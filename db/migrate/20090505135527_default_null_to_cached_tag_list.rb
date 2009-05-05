class DefaultNullToCachedTagList < ActiveRecord::Migration
  def self.up
    #change_column :posts, :cached_tag_list, :string, :default => nil, :null => true
    remove_column :posts, :cached_tag_list
    #add_column :posts, :cached_tag_list, :string, :default => nil, :null => true
  end

  def self.down
    #change_column :posts, :cached_tag_list, :string
    #remove_column :posts, :cached_tag_list
    add_column :posts, :cached_tag_list, :string
  end
end
