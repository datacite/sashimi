require 'rails_helper'
require 'pp'

describe '/heartbeat', type: :request do
  it "get heartbeat" do
    get '/heartbeat'
    print response
    pp response
    
    expect(response.status).to eq(200)
    expect(response.body).to eq("OK")
  end
end
