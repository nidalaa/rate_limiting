require 'spec_helper'

include Rack::Test::Methods

describe RateLimiting do

  def app
    RateLimiting::LimitsManager.new(lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] }, {:limit => 247})
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
      expect(last_response.headers['X-RateLimit-Limit']).to eq(247)
    end
  end

  describe '`X-RateLimit-Remaining` header' do
    it 'is added' do
      get '/'
      expect(last_response.headers.keys).to include('X-RateLimit-Remaining')
    end

    it 'decreases after each request' do
      get '/'
      expect(last_response.headers['X-RateLimit-Remaining']).to eq(246)
      
      6.times { get '/' }
      expect(last_response.headers['X-RateLimit-Remaining']).to eq(240)
    end
  end

  
end
