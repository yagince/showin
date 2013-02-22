require 'base64'
require 'hmac-sha1'
require 'time'

class TwitterClient
  OAUTH_SIGNATURE_PREFIX = "oauth_signature="
  OAUTH_TOKEN_PREFIX = "oauth_token="
  OAUTH_SECRET_PREFIX = "oauth_token_secret="
  USER_ID_PREFIX="user_id="
  SCREEN_NAME_PREFIX="screen_name="

  def initialize
    @oauth_nonce = Time.now.to_i.to_s
    @oauth_timestamp = Time.now.to_i.to_s
    
    @base_url_param =
      "oauth_consumer_key=#{Rho::RhoConfig.twitter_consumer_key}&" +
      "oauth_nonce=#{@oauth_nonce}&" +
      "oauth_signature_method=#{Rho::RhoConfig.twitter_oauth_signature_method}&" +
      "oauth_timestamp=#{@oauth_timestamp}&" +
      "oauth_version=#{Rho::RhoConfig.twitter_oauth_version}&"
  end

  def request_token(callback_url)
    params = url_param(oauth_callback: callback_url)
    response = Rho::AsyncHttp.post(url: Rho::RhoConfig.twitter_request_token_url,
                                   body: params + OAUTH_SIGNATURE_PREFIX + auth_signature(Rho::RhoConfig.twitter_request_token_url, params))
    parse_request_token(response)
  end

  def access_token(oauth_verifier, request_token)
    params = url_param(oauth_verifier: oauth_verifier, oauth_token: request_token.token)
    access_res = Rho::AsyncHttp.post(:url => Rho::RhoConfig.twitter_access_token_url,
                                     :body => params + OAUTH_SIGNATURE_PREFIX + auth_signature(Rho::RhoConfig.twitter_access_token_url, params, request_token.secret))
    parse_access_token(access_res)
  end

  private
  def url_param(options)
    options.inject(@base_url_param){|acc, (key, value)|
      acc + "#{key}=#{value}&"
    }
  end

  def parse_request_token(response)
    response["body"].split("&").inject({}) do |acc, response_line|
      acc[:token] = response_line[OAUTH_TOKEN_PREFIX.length..(response.length - 1)] if response_line.index(OAUTH_TOKEN_PREFIX)
      acc[:secret] = response_line[OAUTH_SECRET_PREFIX.length..(response.length - 1)] if response_line.index(OAUTH_SECRET_PREFIX)
      acc
    end
  end

  def parse_access_token(response)
    response["body"].split("&").inject({}) do |acc, response_line|
      acc[:token] = response[OAUTH_TOKEN_PREFIX.length..(response.length - 1)] if response_line.index(OAUTH_TOKEN_PREFIX)
      acc[:secret]  = response[OAUTH_SECRET_PREFIX.length..(response.length - 1)] if response.index(OAUTH_SECRET_PREFIX)
      acc[:user_id]= response[USER_ID_PREFIX.length..(response.length - 1)] if response.index(USER_ID_PREFIX)
      acc[:screen_name] = response[SCREEN_NAME_PREFIX.length..(response.length - 1)] if response.index(SCREEN_NAME_PREFIX)
      acc
    end
  end

  def auth_signature(url, url_param, secret="")
    signature = "POST&" + Rho::RhoSupport.url_encode(url).to_s +
                "&" + Rho::RhoSupport.url_encode(url_param).to_s

    key = Rho::RhoConfig.twitter_consumer_secret + "&" + secret
    hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    Base64.encode64("#{hmac.digest}")
  end
end
