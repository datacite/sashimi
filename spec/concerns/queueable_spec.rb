require 'rails_helper'

describe Report, vcr: true do
  subject { create(:report) }

  context "queue_report" do
    let(:client) { create(:client) }

    subject { build(:report) }

    it 'should queue' do
      options = {}
      # expect(subject.queue_report(options)).to eq({"queue_url":"test_usage","message_body":{"report_id":"dsr-12hd-zt1"},"message_attributes":{"report-id":{"string_value":"dsr-12hd-zt1","data_type":"String"}}}.to_s)
    end

    it 'report_url' do
      expect(subject.report_url).to eq("https://metrics.test.datacite.org/reports/#{subject.report_id}")
    end
  end
end
