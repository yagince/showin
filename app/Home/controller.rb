require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'lib/social/provider'

class HomeController < Rho::RhoController
  include BrowserHelper

  # GET /Account
  def index
    @msg = "hoge"
  end
end
