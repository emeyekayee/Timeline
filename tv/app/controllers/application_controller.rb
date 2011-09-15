# Filters added to this controller apply to all controllers in the
# application.  Likewise, all the methods added will be available for
# all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '52595a69a1d72bc92c3dc17e57e16bab'
  
  # Commented out in transition to Rails 2.3.8 (Wed Jul 27, '11)
  # session :session_key => '_program_grid_session_id'
  # session_store = :active_record_store

  # See ActionController::Base for details Uncomment this to filter
  # the contents of submitted sensitive data parameters from your
  # application log (in this case, all fields with names like
  # "password").  filter_parameter_logging :password
end
