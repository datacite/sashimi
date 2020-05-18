require "rails_helper"

describe Report, type: :model do
  let(:subject)  { create(:report) }

  describe "validations" do
    it { should validate_presence_of(:report_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:created) }
    it { should validate_presence_of(:reporting_period) }
  end

  describe "transfer" do
    let(:options) { { client_id: subject.client_id, target_id: "BL" } }
    let(:bad_options) { { client_id: "fake.fake", target_id: "BL" } }

    it "works" do
      expect(Report.where(provider_id: "BL").length).to eq(0)

      transfer = Report.transfer(options)
      expect(transfer).to be_truthy

      expect(Report.where(provider_id: "BL").length).to eq(1)
    end

    it "not existent client_id" do
      expect{ Report.transfer(bad_options) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
