class Service < ActiveRecord::Base

  SERVICE_NAME = nil

  has_many :posts

  serialize :settings, Hash

  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}

  validates_presence_of :type, :name, :profile_url
  validates_uniqueness_of :name, :profile_url

  def after_initialize
    self.name = self.class::SERVICE_NAME if self.new_record?
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

end
