require 'spec_helper'

include Rack::Test::Methods

describe RateLimiting do

  def app
    RateLimiting::LimitsManager.new(lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] }, {:limit => 22})
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
  end

  it 'do not allow to access app after the limit is exceed' do
    22.times { get '/' }
      expect(last_response.status).to eq(429)
  end
 
  
end
