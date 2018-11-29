require 'rails_helper'

describe ReportSubset, type: :model do
  let(:subject)  { create(:report_subset) }

  describe "validations" do
    # it { should validate_presence_of(:compressed) }
    it { should validate_presence_of(:report_id) }
    # it { should validate_presence_of(:checksum) }
  end
end
