require 'spec_helper'

include Rack::Test::Methods

describe RateLimiting do

  def app
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] }
  end

  it 'response with success' do
    get '/'
    expect last_response.ok?
  end
end
