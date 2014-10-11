require 'spec_helper'

include Rack::Test::Methods

describe RateLimiting do

  def app
    RateLimiting::LimitsManager.new(lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] })
  end

  it 'response with success' do
    get '/'
    expect last_response.ok?
  end

  it 'adds `X-RateLimit-Limit` header to a response' do
    get '/'
    expect(last_response.headers.keys).to include('X-RateLimit-Limit')
  end
end
