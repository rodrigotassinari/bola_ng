source 'http://rubygems.org'

# para agradar o passenger, que chama duas vezes Bundle.setup(), se não chamar 
# o bundler no Gemfile ele vai achar que não tem bundler instalado, ver:
#   http://www.modrails.com/documentation/Users%20guide%20Apache.html#bundler_support
gem 'bundler' #, '0.9.26'

gem 'rails', '2.3.8'
gem 'mysql', '2.8.1'
gem 'memcache-client', '1.8.3'
gem 'system_timer' # para agradar o memcache-client

gem 'haml', '3.0.13'
gem 'authlogic', '2.1.5'
gem 'will_paginate', '2.3.14'
gem 'settingslogic', '1.0.4'
gem 'twitter', '0.9.7'
gem 'newrelic_rpm', '2.12.3'
gem 'RedCloth', '4.2.3'
gem 'hpricot', '0.8.2'
gem 'whenever', '0.5.0'

group :development do
  gem 'capistrano'
  gem 'wirble'
  gem 'ruby-debug'
  gem 'ruby-debug-ide'
end

group :test do
  gem 'rspec-rails', '1.3.2'
  gem 'remarkable_rails', '3.1.13'
end

