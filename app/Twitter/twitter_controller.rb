require 'rho/rhocontroller'
require 'helpers/browser_helper'

class TwitterController < Rho::RhoController
  include BrowserHelper
  CALL_BACK_URL = "http://127.0.0.1:#{System.get_property('rhodes_port').to_s}/app/Twitter/callback"

  def create
    $request_token = Twitter.new.request_token(CALL_BACK_URL)
    WebView.navigate Rho::RhoConfig.twitter_request_redirect_url + request_token.token
  end

  def callback
    access_token = Twitter.new.access_token(@params["oauth_verifier"], $request_token)
    twitter_accounts = Account.find(:all, conditions: { provider: :twitter })
    if twitter_accounts.empty?
      Account.new(provider: :twitter, token: access_token[:token], secret: access_token[:secret], name: access_token[:screen_name], user_id: access_token[:user_id]).save
    else
      twitter_accounts.first.update_attributes(token: access_token[:token], secret: access_token[:secret], name: access_token[:screen_name], user_id: access_token[:user_id])
    end
    redirect :controller => 'Settings', :action => 'index'
  end
end
