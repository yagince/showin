module Social
  class Provider
    def self.all
      [Twitter, Facebook, Google, Github]
    end
  end

  class Twitter
    def self.name
      "twitter"
    end
  end
  class Facebook
    def self.name
      "facebook"
    end
  end
  class Google
    def self.name
      "google"
    end
  end
  class Github
    def self.name
      "github"
    end
  end
end
