require 'lib/to_hash'
require 'lib/social/user'
require 'time'

module Social
  class Timeline
    include ToHash
    attr_reader :id, :user, :body, :created_at, :account, :urls, :original_data
  end

  class Tweet < Timeline
    def initialize(json, account)
      tweet = json["retweeted_status"] || json
      @original_data = json
      @id = json["id_str"]
      @user = Social::TwitterUser.new(tweet["user"])
      @body = tweet["text"]
      @created_at = Time.parse(tweet["created_at"])
      @account = { name: account.name, provider: account.provider}
      @urls = [tweet["entities"]["urls"]].flatten
    end
  end
end
