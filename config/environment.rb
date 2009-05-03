# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  
  # app, frozen
  config.gem 'haml', :version => '>= 2.0.9'
  config.gem 'authlogic', :version => '>= 2.0.11'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :version => '>= 2.3.8', :source => 'http://gems.github.com'
  config.gem 'settingslogic', :version => '>= 1.0.3'

  # api's, installed
  config.gem 'twitter', :version => '>= 0.6.8'
  config.gem 'ctagg-flickr', :lib => 'flickr', :version => '>= 1.0.8', :source => 'http://gems.github.com'
  config.gem 'xhochy-scrobbler', :lib => 'scrobbler', :version => '>= 0.2.14', :source => 'http://gems.github.com' # aguardar passar pra 2.0
  config.gem 'youtube-g', :lib => 'youtube_g', :version => '>= 0.5.0'
  config.gem 'matthooks-vimeo', :lib => 'vimeo', :version => '>= 0.2.2', :source => 'http://gems.github.com'
  config.gem 'www-delicious', :lib => 'www/delicious', :version => '>= 0.3.0'

  config.gem 'hpricot', :version => '>= 0.8.1'

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