class OauthAuthorizeController < ApplicationController

	def authorize_google_api
	  google_oauth_service = GoogleOauthService.new(current_user)
	  google_oauth_service.set_access_token(params[:code])
	  google_oauth_service.refresh_access_token
	  redirect_to root_path, :notice => "you have been successfully authorized!"
  end
end
