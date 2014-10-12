require 'spec_helper'
require 'timecop'

include Rack::Test::Methods

describe RateLimiting do

  def app
    RateLimiting::LimitsManager.new(lambda do |env|
                                      [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]]
                                    end,
      {:limit => 22, :reset_in => 3600})
  end

  it 'response with success' do
    get '/'
    expect last_response.ok?
  end

  describe '`X-RateLimit-Limit` header' do
    it 'is added' do
      get '/'
      expect(last_response.headers.keys).to include('X-RateLimit-Limit')
    end

    it 'has value from :limit in middelware constructor' do
      get '/'
      expect(last_response.headers['X-RateLimit-Limit']).to eq(22)
    end
  end

  describe '`X-RateLimit-Remaining` header' do
    it 'is added' do
      get '/'
      expect(last_response.headers.keys).to include('X-RateLimit-Remaining')
    end

    it 'decreases after each request' do
      get '/'
      expect(last_response.headers['X-RateLimit-Remaining']).to eq(21)

      4.times { get '/' }
      expect(last_response.headers['X-RateLimit-Remaining']).to eq(17)
    end

    it 'do not allow to access app after the limit is exceed' do
      22.times { get '/' }
      expect(last_response.status).to eq(429)
    end
  end

  describe '`X-RateLimit-Reset` header' do
    before(:each) do
      get '/'
      @initial_request_time = Time.now
    end

    it 'is added' do
      expect(last_response.headers.keys).to include('X-RateLimit-Reset')
    end

    it 'counts the time to reset' do
      Timecop.freeze(@initial_request_time + 600) do
        get '/'
        expect(last_response.headers['X-RateLimit-Reset']).to be_within(0.1).of(3000)
      end
    end

    it 'resets time after specified time' do
      Timecop.freeze(@initial_request_time + 3700) do
        get '/'
        expect(last_response.headers['X-RateLimit-Reset']).to be_within(0.1).of(3500)
      end 
    end

    it 'resets limit after specifed time' do
      10.times { get '/' }

      Timecop.freeze(@initial_request_time + 3700) do
        get '/'
        expect(last_response.headers['X-RateLimit-Remaining']).to eq(21)
      end 
    end
  end
  
end
