class TwitterService < Service

  SERVICE_NAME = 'Twitter'
  #SERVICE_ACTIONS = [:tweeted]

  validates_presence_of :twitter_login

  settings_accessors(:twitter_login)

end
