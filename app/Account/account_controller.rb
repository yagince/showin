require 'rho/rhocontroller'
require 'helpers/browser_helper'

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
    render back: (url_for action: index)
  end

  # POST /Account/create
  def create
    case @params['provider']
    when 'twitter'
      redirect :controller => 'Twitter', :action => :create
    else
      # TODO: other platform
      redirect :controller => 'Twitter', :action => :create
    end
  end
end
