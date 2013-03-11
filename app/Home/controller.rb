require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'lib/simple_struct'
require 'lib/social/provider'
require 'lib/social/twitter_client'
require 'json'

class HomeController < Rho::RhoController
  include BrowserHelper

  # GET /Account
  def index
    @timelines = Account.find_all.inject([]) {|acc, account|
      client = account.client_klass.new
      acc << client.home_timelines(account, count: 10, exclude_replies: true, contributor_details: false, include_entities: false)
    }.flatten.sort{|a,b| b.created_at <=> a.created_at}
    @hoge = "hoge"
    if xhr?
      render string: ::JSON.generate(@timelines.inject([]){|acc, timeline| acc << timeline.to_hash})
    end
  end

  def newest_timeline
    @timelines = [{body: "hoge"},{body: "foo"}]
    RhoLog.info("Home", @timelines.to_json.to_s)
    render string: @timelines.to_json.to_s
  end
end
