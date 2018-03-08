require 'rails_helper'

describe User, type: :model do
  let(:token) { User.generate_token }
  subject { User.new(token) }

  describe 'decode_token' do
    it "has name" do
      payload = subject.decode_token(token)
      expect(payload["name"]).to eq("Josiah Carberry")
    end

    it "empty token" do
      payload = subject.decode_token("")
      expect(payload).to be_empty
    end

    it "invalid token" do
      payload = subject.decode_token("abc")
      expect(payload).to be_empty
    end
  end

  describe 'encode_token' do
    it "with name" do
      token = subject.encode_token("name" => "Josiah Carberry")
      expect(token).to start_with("eyJhbG")
    end

    it "empty string" do
      token = subject.encode_token("")
      expect(token).to be_nil
    end
  end
end
