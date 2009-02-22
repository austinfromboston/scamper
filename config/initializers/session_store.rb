# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_scamper_session',
  :secret      => 'c0ef9faf14715ab1b64a1e7a4c152715dbedff9317147f38b9f7453b27370f53a62de4103873a08ceb23fd53d3f3000548e032ac9dafc7c09323313fed1a6451'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
