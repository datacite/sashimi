require 'rails_helper'

describe Report, type: :model do
  let(:report)  { create(:report) }

  describe "validations" do
    it { should validate_presence_of(:report_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:created) }
    it { should validate_presence_of(:report_datasets) }
  end
end
