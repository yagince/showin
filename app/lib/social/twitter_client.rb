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
    response = request(:post, Rho::RhoConfig.twitter_request_token_url, callback: callback_url)
    parse_request_token(response)
  end

  def access_token(oauth_verifier, request_token)
    access_res = request(:post, Rho::RhoConfig.twitter_access_token_url, token: request_token.token)
    parse_access_token(access_res)
  end

  DEFAULT_HOME_TIMELINE_OPTIONS = {count: 0, since: 0}
  def home_timelines(account, options={})
    url = to_url(Rho::RhoConfig.twitter_home_timeine_url, DEFAULT_HOME_TIMELINE_OPTIONS.merge(options))
    response = request_with_account(:get, url, account)
    error?(response) ? [] : parse_timelines(response, account)
  end

  def timeline(account, options={})
    url = to_url(Rho::RhoConfig.twitter_statuses_show_url, options)
    response = Rho::AsyncHttp.get(url: url,
                                  headers: header_with_account(:get, url, account))
    response = request_with_account(:get, url, account)
    error?(response) ? nil : parse_timeline(response, account)
  end

  private
  def consumer_token
    { consumer_key: Rho::RhoConfig.twitter_consumer_key,
      consumer_secret: Rho::RhoConfig.twitter_consumer_secret }
  end

  def request(method, url, options={})
    Rho::AsyncHttp.send(method, url: url, headers: header(method, url, options))
  end

  def request_with_account(method, url, account)
    Rho::AsyncHttp.send(method, url: url, headers: header_with_account(method, url, account))
  end

  def header(method, url, header_options)
    { :Authorization => Social::OauthHeader.new(method, url, {}, consumer_token.merge(header_options)) }
  end

  def header_with_account(method, url, account)
    header(method, url, token: account.token, token_secret: account.secret)
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

  def parse_timelines(response, account)
    response["body"].map{|timeline| RhoLog.info("timeline", timeline);Social::Tweet.new(timeline, account)}
  end

  def parse_timeline(response, account)
    Social::Tweet.new(response["body"], account)
  end

  def error?(response)
    body = response["body"]
    !!(body.kind_of?(Hash) && body["errors"])
  end

  def to_url(uri, params)
    params.inject("#{uri}?"){|acc, (key, value)| (value.respond_to?(:zero?) && value.zero?) ? acc : "#{acc}#{key}=#{value}&" }.chop
  end
end
