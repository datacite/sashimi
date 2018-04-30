require 'rails_helper'

describe Report, vcr: true do
  subject { create(:report) }

  context "register_report" do
    let(:client) { create(:client) }

    subject { build(:report, report: "10.5438/mcnv-ga6n", client: client) }

    it 'should register' do
      options = { url: "https://blog.datacite.org/re3data-science-europe/", username: ENV['MDS_USERNAME'], password: ENV['MDS_PASSWORD'] }
      expect(subject.register_url(options).body).to eq("data"=>"OK")
    end

    it 'missing username and password' do
      options = { url: "https://blog.datacite.org/re3data-science-europe/" }
      expect(subject.register_url(options).body).to eq("errors"=>[{"title"=>"Username or password missing"}])
    end

    it 'wrong username and password' do
      options = { url: "https://blog.datacite.org/re3data-science-europe/", username: ENV['MDS_USERNAME'], password: 12345 }
      expect(subject.register_url(options).body).to eq("errors"=>[{"status"=>401, "title"=>"Unauthorized"}])
    end
  end
end
