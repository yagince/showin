require 'lib/to_hash'
require 'lib/social/user'
require 'time'

module Social
  class Timeline
    include ToHash
    attr_reader :id, :user, :body, :created_at, :account
  end

  class Tweet < Timeline
    def initialize(json, account)
      @id = json["id_str"]
      @user = Social::TwitterUser.new(json["user"])
      @body = json["text"]
      @created_at = Time.parse(json["created_at"])
      @account = { name: account.name, provider: account.provider}
    end
  end
end
