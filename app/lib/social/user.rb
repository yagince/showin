module Social
  class User
    attr_reader :id, :name, :profile_image_url, :profile_url

    def initialize(json)
      @id = json["id"]
      @name = json["name"]
      @profile_image_url = json["profile_image_url"]
      @profile_url = json["url"]
    end
  end
end
