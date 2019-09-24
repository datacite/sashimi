require 'rails_helper'

describe Report, vcr: true do
  subject { create(:report) }

  context "queue_report" do
    let(:client) { create(:client) }

    subject { build(:report) }

    it 'should queue' do
      # expect(subject.queue_report()).to eq('{"queue_url":"test_usage","message_body":{"report_id":"https://metrics.test.datacite.org/reports/dsr-12hd-zt1"}}')
    end

    it 'report_url' do
      # expect(subject.report_url).to eq("https://metrics.test.datacite.org/reports/")
    end

    it 'sqs' do
      # expect(subject.sqs).to respond_to(:send_message)
    end
  end
end

