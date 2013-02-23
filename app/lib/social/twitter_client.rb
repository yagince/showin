require 'base64'
require 'hmac-sha1'
require 'time'
require 'lib/social/oauth_header'
require 'lib/simple_struct'

class Social::TwitterClient
  OAUTH_SIGNATURE_PREFIX = "oauth_signature="
  OAUTH_TOKEN_PREFIX = "oauth_token="
  OAUTH_SECRET_PREFIX = "oauth_token_secret="
  USER_ID_PREFIX="user_id="
  SCREEN_NAME_PREFIX="screen_name="

  def request_token(callback_url)
    response = Rho::AsyncHttp.post(url: Rho::RhoConfig.twitter_request_token_url,
                                   headers: header(:post, Rho::RhoConfig.twitter_request_token_url, callback: callback_url))
    parse_request_token(response)
  end

  def access_token(oauth_verifier, request_token)
    access_res = Rho::AsyncHttp.post(:url => Rho::RhoConfig.twitter_access_token_url,
                                     headers: header(:post, Rho::RhoConfig.twitter_access_token_url, token: request_token.token))
    RhoLog.info("Client#access_token", access_res)
    parse_access_token(access_res)
  end

  private
  def consumer_token
    { consumer_key: Rho::RhoConfig.twitter_consumer_key,
      consumer_secret: Rho::RhoConfig.twitter_consumer_secret }
  end
  def header(method, url, header_options)
    { :Authorization => Social::OauthHeader.new(method, url, {}, consumer_token.merge(header_options)) }
  end
  def parse_request_token(response)
    SimpleStruct.new(response["body"].split("&").inject({}){ |acc, response_line|
      acc[:token] = response_line[OAUTH_TOKEN_PREFIX.length..(response_line.length - 1)] if response_line.index(OAUTH_TOKEN_PREFIX)
      acc[:secret] = response_line[OAUTH_SECRET_PREFIX.length..(response_line.length - 1)] if response_line.index(OAUTH_SECRET_PREFIX)
      acc
    })
  end
  def parse_access_token(response)
    SimpleStruct.new(response["body"].split("&").inject({}){ |acc, response_line|
      acc[:token] = response_line[OAUTH_TOKEN_PREFIX.length..(response_line.length - 1)] if response_line.index(OAUTH_TOKEN_PREFIX)
      acc[:secret]  = response_line[OAUTH_SECRET_PREFIX.length..(response_line.length - 1)] if response_line.index(OAUTH_SECRET_PREFIX)
      acc[:user_id]= response_line[USER_ID_PREFIX.length..(response_line.length - 1)] if response_line.index(USER_ID_PREFIX)
      acc[:screen_name] = response_line[SCREEN_NAME_PREFIX.length..(response_line.length - 1)] if response_line.index(SCREEN_NAME_PREFIX)
      acc
    })
  end
end
