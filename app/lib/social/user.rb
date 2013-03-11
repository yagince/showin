require 'lib/to_hash'
module Social
  class User
    include ToHash
    attr_reader :id, :name, :profile_image_url, :profile_url, :account_name
  end

  class TwitterUser < User
    def initialize(json)
      @id = json["id"]
      @name = json["name"]
      @profile_image_url = json["profile_image_url"]
      @profile_url = json["url"]
      @account_name = json["screen_name"]
    end
  end
end
