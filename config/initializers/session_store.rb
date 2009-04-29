# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bola_ng_session',
  :secret      => '00b26dedaf0d9ed661117920c814d3f9ecbbadcc268cde84817297e849fa0a7e22c1c00783ef532d841debf8f5ec8ea96a02ad22faa99fb7453763d7c9aa59cb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
