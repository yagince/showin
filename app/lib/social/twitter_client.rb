require 'base64'
require 'hmac-sha1'
require 'json'
require 'time'
require 'lib/social/oauth_header'
require 'lib/social/timeline'
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
    parse_access_token(access_res)
  end

  DEFAULT_HOME_TIMELINE_OPTIONS = {count: 0, since: 0}
  def home_timelines(account, options={})
    url = to_url(Rho::RhoConfig.twitter_home_timeine_url, DEFAULT_HOME_TIMELINE_OPTIONS.merge(options))
    response = Rho::AsyncHttp.get(url: url,
                                  headers: header(:get, url, token: account.token, token_secret: account.secret))
    RhoLog.info("TwitterClient#home_timelines", "response class is #{response["body"].class}")
    error?(response) ? [] : parse_timeline(response)
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

  def parse_timeline(response)
    response["body"].map{|timeline| Social::Tweet.new(timeline)}
  end

  def error?(response)
    body = response["body"]
    !!(body.kind_of?(Hash) && body["errors"])
  end

  def to_url(uri, params)
    params.inject("#{uri}?"){|acc, (key, value)| (value.respond_to?(:zero?) && value.zero?) ? acc : "#{acc}#{key}=#{value}&" }.chop
  end
end
