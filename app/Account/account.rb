require 'lib/social/twitter_client'

class Account
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Account.
  # enable :sync

  #add model specific code here
  def client_klass
    case self.provider
    when :twitter
      Social::TwitterClient
    else
      # TODO: other platform
      Social::TwitterClient
    end
  end
end
