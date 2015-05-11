class ApplicationController < ActionController::Base
require 'google_auth'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def refresh_token
    @google_oauth_service.refresh_access_token
  end

  def google_oauth_service
    @google_oauth_service = GoogleOauthService.new(current_user, current_user.google_profile_id)
    if current_user.ggl_access_token
      @google_oauth_service.restore_access_token
      if @google_oauth_service.expired?
        refresh_token
      end
    end
  end

end
