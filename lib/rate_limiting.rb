require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app, options={})
      @app = app
      @limit = options[:limit] || 60
      @ramaining_limit = @limit
    end
    
    def call(env)
      status, headers, response = @app.call(env)
      @ramaining_limit -= 1

      headers.merge!('X-RateLimit-Limit' => @limit, 'X-RateLimit-Remaining' => @ramaining_limit)
      [status, headers, response]
    end
  end
end
