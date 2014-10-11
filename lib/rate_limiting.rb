require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app, options={})
      @app = app
      @options = options
    end
    
    def call(env)
      status, headers, response = @app.call(env)

      limit = @options[:limit] || 60
      headers.merge!('X-RateLimit-Limit' => limit)
      [status, headers, response]
    end
  end
end
