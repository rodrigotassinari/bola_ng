class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.string   :type
      t.string   :name
      t.string   :icon_url
      t.string   :profile_url
      t.string   :profile_image_url
      t.text     :settings
      t.boolean  :active, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
