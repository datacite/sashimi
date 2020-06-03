require 'rails_helper'

describe Report, vcr: true do
  subject { create(:report) }

  context "send_message" do
    let(:client) { create(:client) }

    subject { build(:report) }

    it 'should queue' do
      # expect(subject.send_message(subject.report_url)).to eq('{"queue_url":"test_usage","message_body":{"report_id":"https://metrics.stage.datacite.org/reports/dsr-12hd-zt1"}}')
    end

    it 'report_url' do
      # expect(subject.report_url).to eq("https://metrics.stage.datacite.org/reports/")
    end

    it 'sqs' do
      # expect(subject.sqs).to respond_to(:send_message)
    end
  end
end
