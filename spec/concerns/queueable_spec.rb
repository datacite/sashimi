require 'rails_helper'

describe Report, vcr: true do
  subject { create(:report) }

  context "queue_report" do
    let(:client) { create(:client) }

    subject { build(:report) }

    it 'should queue' do
      options = {}
      expect(subject.queue_report(options).body).to eq("data"=>"OK")
    end
  end
end
