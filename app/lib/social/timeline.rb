require 'lib/social/user'
require 'date'

module Social
  class Timeline
    attr_reader :id, :user, :body, :created_at
  end

  class Tweet < Timeline
    def initialize(json)
      @id = json["id"]
      @user = Social::User.new(json["user"])
      @body = json["text"]
      @created_at = DateTime.parse(json["created_at"])
    end
  end
end
