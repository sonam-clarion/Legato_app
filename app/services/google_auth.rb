require 'oauth2'

class GoogleOauthService

  GOOGLE_OAUTH_CLIENT_ID = ENV['GOOGLE_OAUTH_CLIENT_ID']
  GOOGLE_OAUTH_SECRET_KEY = ENV['GOOGLE_OAUTH_SECRET_KEY']
  GOOGLE_REDIRECT_HOST = ENV['GOOGLE_REDIRECT_HOST']

  GOOGLE_REDIRECT_PATH = ENV['GOOGLE_REDIRECT_PATH']
  GOOGLE_REDIRECT_URI = "#{GOOGLE_REDIRECT_HOST}#{ENV['GOOGLE_REDIRECT_PATH']}"
  QUERY_ROOT = "https://www.googleapis.com/analytics/v3/data/ga?"

  attr_reader :ga_id, :oauth_auth_code, :client, :user

  def initialize(user, ga_id=nil)
    @user = user
    @ga_id = ga_id if ga_id
    @client = OAuth2::Client.new(GOOGLE_OAUTH_CLIENT_ID, GOOGLE_OAUTH_SECRET_KEY, {
      :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
      :token_url => 'https://accounts.google.com/o/oauth2/token'
    })
  end

  def get_authorize_url
    url = @client.auth_code.authorize_url({
      :scope => 'https://www.googleapis.com/auth/analytics.readonly',
      :redirect_uri => GOOGLE_REDIRECT_URI,
      :access_type => 'offline'
    })
    url #copy this url into browser
  end

  def set_access_token(code=nil)
    @access_token = @client.auth_code.get_token(code || @oauth_auth_code,
      {:redirect_uri => GOOGLE_REDIRECT_URI})
    @serialized_access_token = @access_token.to_hash.to_json
    user.update_attribute(:ggl_access_token, @serialized_access_token)
    nil
  end

  def get_sessions_and_pageviews_by_country
    query = "start-date=2015-01-01&end-date=2015-02-01&metrics=ga:sessions,ga:pageviews&dimensions=ga:country"
    response_json = @access_token.get("#{QUERY_ROOT}ids=ga:#{@ga_id}&#{query}").body
    JSON.parse(response_json)
  end

  def execute_query(query)
    response_json = @access_token.get("#{QUERY_ROOT}ids=ga:#{@ga_id}&#{query}").body
    JSON.parse(response_json)
  end

  def restore_access_token
    @serialized_access_token = user.ggl_access_token
    @access_token = OAuth2::AccessToken.from_hash @client,
    {:refresh_token => JSON.parse(@serialized_access_token)['refresh_token'],
    :access_token => JSON.parse(@serialized_access_token)['access_token'],
    :expires_at => JSON.parse(@serialized_access_token)['expires_at']}
    nil
  end

  def expired?
    restore_access_token unless @access_token
    @access_token.expired?
  end

  def access_token_object
    restore_access_token unless @access_token
    @access_token
  end

  def access_token
    restore_access_token unless @access_token
    @access_token.token
  end

  def refresh_token
    restore_access_token unless @access_token
    @access_token.refresh_token
  end

  def refresh_access_token
    restore_access_token unless @access_token
    @access_token = @access_token.refresh!
    @serialized_access_token = @access_token.to_hash.to_json
    user.update_attribute(:ggl_access_token, @serialized_access_token)
    nil
  end

end
