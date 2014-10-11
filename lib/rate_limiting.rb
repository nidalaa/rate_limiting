require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app)
      @app = app
    end
    
    def call(env)
      status, headers, response = @app.call(env)
      headers.merge!('X-RateLimit-Limit' => '')
      [status, headers, response]
    end
  end
end
