require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'lib/social/provider'

class AccountController < Rho::RhoController
  include BrowserHelper

  # GET /Account
  def index
    @accounts = Account.find(:all)
    render :back => '/Settings'
  end

  # GET /Account/{1}
  def show
    @account = Account.find(@params['id'])
    if @account
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  def new
    @msg = @params["msg"]
    render back: (url_for action: index)
  end

  # POST /Account/create
  # TODO: delete
  def create
    case @params['provider']
    when 'twitter'
      RhoLog.info("Account", "redirect to TwitterController")
      redirect :controller => :Twitter, :action => :create, :query => @params
    else
      # TODO: other platform
      redirect :action => :index
    end
  end
end
