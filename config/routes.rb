ActionController::Routing::Routes.draw do |map|
  ## public

  map.resources :lifestream, :controller => 'lifestream'

  map.resources :blog, :controller => 'blog'

  map.tag_name 'tag/:name',
    :controller => 'tags',
    :action => 'show',
    :conditions => {:method => :get},
    :name => /.*/

  map.resources :tags

  map.with_options(:controller => 'pages', :conditions => {:method => :get}) do |pages|
    pages.about 'about', :action => 'about'
    pages.contact 'contact', :action => 'contact'
  end

  map.resource :user_session
  map.with_options(:controller => 'user_sessions') do |us|
    us.login 'login', :action => 'new'
    us.logout 'logout', :action => 'destroy'
  end

  ## admin

  map.resources :posts

  ## defaults

  map.root :controller => 'lifestream', :action => 'index'

  # old redirects
  map.with_options(:controller => 'pages', :conditions => {:method => :get}) do |old|
    old.connect 'sobre', :action => 'about'
    old.connect 'contato', :action => 'contact'
    old.connect ':year/:month/:day/:slug', :action => 'old_redirect',
      :year => /\d{4}/,
      :month => /\d{1,2}/,
      :day => /\d{1,2}/,
      :slug => /[a-zA-Z0-9_-]+/
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
