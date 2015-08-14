require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/oauth2_refresh'
require 'oauth2'

module RingCentralSdk::Platform
  class Platform

    ACCESS_TOKEN_TTL  = 600             # 10 minutes
    REFRESH_TOKEN_TTL = 36000           # 10 hours
    REFRESH_TOKEN_TTL_REMEMBER = 604800 # 1 week
    ACCOUNT_PREFIX    = '/account/'
    ACCOUNT_ID        = '~'
    TOKEN_ENDPOINT    = '/restapi/oauth/token'
    REVOKE_ENDPOINT   = '/restapi/oauth/revoke'
    API_VERSION       = 'v1.0'
    URL_PREFIX        = '/restapi'

    attr_accessor :server_url
    attr_accessor :client

    def initialize(app_key='', app_secret='', server_url=RingCentralSdk::Sdk::RC_SERVER_SANDBOX)

      @app_key    = app_key
      @app_secret = app_secret
      @server_url = server_url
      @token      = nil
      @client     = nil

    end

    def get_api_version_url()
      return @server_url + URL_PREFIX + '/' + API_VERSION 
    end

    def authorize(username='', extension='', password='', remember=false)

      oauth2 = OAuth2::Client.new(@app_key, @app_secret,
        :site      => @server_url,
        :token_url => TOKEN_ENDPOINT)

      token = oauth2.password.get_token(username, password, {
        :extension => extension,
        :headers   => { 'Authorization' => 'Basic ' + get_api_key() } })

      authorized(token)

    end

    def authorized(token=nil)
      @token = token

      @client = Faraday.new(:url => get_api_version_url()) do |conn|
        conn.request  :oauth2_refresh, @token
        conn.request  :json
        conn.request  :url_encoded
        conn.response :json, :content_type => 'application/json'
        conn.adapter  Faraday.default_adapter
      end

    end

    def get_api_key()
      api_key = (@app_key.is_a?(String) && @app_secret.is_a?(String)) \
        ? Base64.encode64("#{@app_key}:#{@app_secret}").gsub(/[\s\t\r\n]/,'') : ''
      return api_key
    end

    def request(helper=nil)
      unless helper.is_a?(RingCentralSdk::Helpers::Request)
        raise 'Request is not a RingCentralSdk::Helpers::Request'
      end

      if helper.method.downcase == 'post'
        resp       =  @client.post do |req|
          req.url helper.url
          req.headers['Content-Type'] = helper.content_type if helper.content_type
          req.body = helper.body if helper.body
        end
        return resp
      end
      return nil
    end
    
    private :get_api_version_url
  end
end
