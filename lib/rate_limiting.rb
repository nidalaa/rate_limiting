require "rate_limiting/version"

module RateLimiting
  class LimitsManager
    def initialize(app, options={})
      @store = {}

      @app = app
      @options = options
    end
    
    def call(env)
      client = env['REMOTE_ADDR'] || "default"
      set_limits(client)
      
      return [429, {'Content-Type' => 'text/plain'}, ["429 Too Many Requests"]] unless @store[client][:remaining_limit] > 0

      status, headers, response = @app.call(env)
      headers.merge!('X-RateLimit-Limit' => @options[:limit], 'X-RateLimit-Remaining' => @store[client][:remaining_limit], 'X-RateLimit-Reset' => @store[client][:remaining_time_limit])
      [status, headers, response]
    end

    private
    def set_limits(client)
      @store[client] ||= {}
      @store[client][:start_time] ||= Time.now
      @store[client][:remaining_limit] ||= @options[:limit]
      
      passed_time = Time.now - @store[client][:start_time]

      if(passed_time / @options[:reset_in] >= 1 )
        @store[client][:remaining_limit] = @options[:limit]
        @store[client][:start_time] = Time.now
      end

      @store[client][:remaining_limit] -= 1
      @store[client][:remaining_time_limit] = @options[:reset_in] - (passed_time % @options[:reset_in])
    end
  end
end
