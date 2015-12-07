require 'redis'

class DataStore
  class << self
    def set(key, object)
      redis.set("dashboard:#{key}", object.to_json)
    end

    def get(key)
      JSON.parse(redis.get("dashboard:#{key}"))
    end

    def clear
      redis.del(redis.keys('dashboard:*'))
    end

    def redis
      Redis.new
    end
  end
end
