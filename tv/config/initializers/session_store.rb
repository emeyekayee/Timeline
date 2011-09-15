# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tv_session',
  :secret      => '78306a6fddcb63bdf6b8134d5b0c6138edca52083ef04918f05e74b0508eb3ddd8d7b184febe4dad5d8292cc6f4fac95d7853a1beea616578a57d8c915c1ba9a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
