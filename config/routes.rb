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

  ## admin

  # TODO

  ## defaults

  map.root :controller => 'lifestream', :action => 'index'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
