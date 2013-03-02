require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'lib/social/provider'
require 'lib/social/twitter_client'

class HomeController < Rho::RhoController
  include BrowserHelper

  # GET /Account
  def index
    @timelines = Account.find_all.inject([]) {|acc, account|
      client = account.client_klass.new
      acc << client.home_timelines(account, count: 10, exclude_replies: true, contributor_details: false, include_entities: false)
    }.flatten.sort{|a,b| a.created_at <=> b.created_at}
  end
end
