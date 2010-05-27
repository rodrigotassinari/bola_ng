# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  
  # frozen
  config.gem 'haml', :version => '3.0.6'
  config.gem 'authlogic', :version => '2.1.5'
  config.gem 'will_paginate', :version => '2.3.12'
  config.gem 'settingslogic', :version => '1.0.4'
  config.gem 'twitter', :version => '0.9.5'
  config.gem 'newrelic_rpm', :version => '2.12.1'

  # installed
  config.gem 'yajl-ruby', :version => '~> 0.7.0', :lib => 'yajl' # dependencia gem twitter
  config.gem 'RedCloth', :version => '4.2.3'
  config.gem 'hpricot', :version => '0.8.2'
  config.gem 'whenever', :version => '0.4.2', :lib => false

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Brasilia' # TODO passar para settings.yml

  # The default locale is :pt and all translations from config/locales/**/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale = :pt # TODO passar para settings.yml
end
