class WelcomeController < ApplicationController
  before_action :google_oauth_service
	def index
		
	end
	def get_google_profiles
    google_user = Legato::User.new(@google_oauth_service.access_token_object)
    abort google_user.profiles.inspect
    @profiles = google_user.profiles.map{|profile| GoogleProfile.new(profile.id, profile.name)}
  end
end
