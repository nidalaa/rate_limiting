require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app, options={})
      @app = app
      @limit = options[:limit] || 60
      @remaining_limit = @limit
    end
    
    def call(env)
      @remaining_limit -= 1
      return [429, {'Content-Type' => 'text/plain'}, ["429 Too Many Requests"]] unless @remaining_limit > 0

      status, headers, response = @app.call(env)
      headers.merge!('X-RateLimit-Limit' => @limit, 'X-RateLimit-Remaining' => @remaining_limit)
      [status, headers, response]
    end
  end
end
