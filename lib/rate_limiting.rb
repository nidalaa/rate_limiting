require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app, options={})
      @app = app
      @limit = options[:limit] || 60
      @remaining_limit = @limit
      @reset_in = options[:reset_in]
    end
    
    def call(env)
      time_limit = set_time_limit
      @remaining_limit -= 1
      return [429, {'Content-Type' => 'text/plain'}, ["429 Too Many Requests"]] unless @remaining_limit > 0

      status, headers, response = @app.call(env)
      headers.merge!('X-RateLimit-Limit' => @limit, 'X-RateLimit-Remaining' => @remaining_limit, 'X-RateLimit-Reset' => time_limit)
      [status, headers, response]
    end

    private
    def set_time_limit
      @start_time ||= Time.now
      passed_time = Time.now - @start_time

      if(passed_time / @reset_in >= 1 )
        @remaining_limit = @limit
        @start_time = Time.now
      end

      @reset_in - (passed_time % @reset_in)
    end
  end
end
