require 'lib/to_hash'
require 'lib/social/user'
require 'time'

module Social
  class Timeline
    include ToHash
    attr_reader :id, :user, :body, :created_at
  end

  class Tweet < Timeline
    def initialize(json)
      @id = json["id"]
      @user = Social::TwitterUser.new(json["user"])
      @body = json["text"]
      @created_at = Time.parse(json["created_at"])
    end
  end
end
