require 'rails_helper'

describe Report, type: :model do
  let(:subject)  { create(:report) }

  describe "validations" do
    it { should validate_presence_of(:report_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:created) }
    # it { should validate_presence_of(:report_datasets) }
    it { should validate_presence_of(:reporting_period) }
  end

  describe "update_state" do
    it "state is queued" do
      expect(subject.aasm_state).to eq("correct")
    end

    it "it is valid" do
      subject.update_state
      expect(subject.aasm_state).to eq("queued")
    end

    it "it is compressed" do
      expect(subject.compressed_report?).to eq(nil)
    end

    it "it is normal" do
      expect(subject.normal_report?).to eq(true)
    end

    it "compressed" do
      expect(subject.compress).to be_a(String)
    end
  end
end
