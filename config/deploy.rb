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

set :ruby_path, "/opt/ree/bin/ruby"
set :rake_path, "/opt/ree/bin/rake"
set :rake,      "/opt/ree/bin/rake"
set :gem_path,  "/opt/ree/bin/gem"
set :god_path,  "/opt/ree/bin/god"

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
    run "cd #{current_path} && bundle install --without test development"
    #run "cd #{release_path} && bundle install --without test development"
  end
end

# Callbacks

after "deploy:update_code", "deploy:shared_symlink"
after "deploy:update_code", "bundler:install"

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"

