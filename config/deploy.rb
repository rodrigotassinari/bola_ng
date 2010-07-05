## configuração

set :application, "bola_ng"

set :scm, :git
set :repository,  "git@github.com:rtopitt/bola_ng.git"
set :branch, "production"
set :deploy_via, :remote_cache

set :domain, "pittlandia.net"

role :web, "97.107.135.29"                          # Your HTTP server, Apache/etc
role :app, "97.107.135.29"                          # This may be the same as your `Web` server
role :db,  "97.107.135.29", :primary => true        # This is where Rails migrations will run

set :deploy_to, "/home/rodrigo/www/pittlandia.net"
set :rails_env, "production"

set :use_sudo, false
set :user, "rodrigo"

set :ruby_path,  "/opt/ree/bin/ruby"
set :rake_path,  "/opt/ree/bin/rake"
set :rake,       "/opt/ree/bin/rake"
set :gem_path,   "/opt/ree/bin/gem"
set :god_path,   "/opt/ree/bin/god"
set :bundle_path, "/opt/ree/bin/bundle"

set :port, 30000 # SSH port
default_run_options[:pty] = true

## Tasks

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Prepare shared files"
  task :shared_setup do
    run "mkdir -p #{shared_path}/config"
    run "cp #{latest_release}/config/database.yml.example #{shared_path}/config/database.yml"
    run "cp #{latest_release}/config/application.yml.example #{shared_path}/config/application.yml"
  end

  desc "Symlink shared configs and folders on each release."
  task :shared_symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{latest_release}/config/application.yml"
  end
end

namespace :bundler do
  desc "Run bundle install on app root"
  task :install do
    run "cd #{current_path} && #{bundle_path} install --without test development"
  end
end

namespace :whenever do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    # IMPORTANT: shell-less ssh login must get the correct PATH via ~/.ssh/environment
    # See: http://brunomiranda.com/past/2007/7/20/capistrano_2_local_deployment_path/
    run "cd #{current_path} && #{bundle_path} exec whenever --set 'path=#{current_path}&output=#{current_path}/log/cron.log' --update-crontab #{domain}"
  end
end

namespace :jammit do
  desc 'Bundle and minify the JS and CSS files'
  task :precache_assets, :roles => :app do
    root_path = File.expand_path(File.dirname(__FILE__) + '/..')
    assets_path = "#{root_path}/public/bundles"
    jammit_path = `which jammit`.chomp
    sass_path = `which sass`.chomp
    run_locally "cd #{root_path} && #{sass_path} --update public/stylesheets/sass:public/stylesheets --cache-location tmp/sass-cache"
    run_locally "cd #{root_path} && #{jammit_path} -c config/assets.yml -f"
    top.upload assets_path, "#{latest_release}/public", :via => :scp, :recursive => true
  end
end

# Callbacks

after "deploy:update_code", "deploy:shared_symlink"
after "deploy:update_code", "bundler:install"

after 'deploy:symlink', 'jammit:precache_assets'
after "deploy:symlink", "whenever:update_crontab"

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
