require "rails_helper"
require "cancan/matchers"

describe User, type: :model do
  let(:token) { User.generate_token }
  let(:user) { User.new(token) }
  let(:report) { create(:report, client_id: "datacite.datacite") }
  let(:report_subset) { create(:report_subset, report_id: report.uid) }

  let(:report_cdl) { create(:report, client_id: "cdl.dash") }
  let(:report_subset_cdl) { create(:report_subset, report_id: report_cdl.uid) }

  describe "User attributes", order: :defined do
    it "is valid with valid attributes" do
      expect(user.name).to eq("staff")
    end
  end

  describe "abilities", vcr: true do
    subject { Ability.new(user) }

    context "when is a staff_admin" do
      let(:token){ User.generate_token(role_id: "staff_admin") }

      it { is_expected.to be_able_to(:read, user) }
      it { is_expected.to be_able_to(:read, report) }
      it { is_expected.to be_able_to(:create, report) }
      it { is_expected.to be_able_to(:update, report) }
      it { is_expected.to be_able_to(:destroy, report) }
    end

    context "when is a client admin" do
      let(:token){ User.generate_token(role_id: "client_admin", uid: "datacite.datacite") }

      it { is_expected.not_to be_able_to(:read, user) }

      it { is_expected.to be_able_to(:read, report) }
      it { is_expected.to be_able_to(:create, report) }
      it { is_expected.to be_able_to(:update, report) }
      it { is_expected.not_to be_able_to(:destroy, report) }

      it { is_expected.not_to be_able_to(:read, report_cdl) }
      it { is_expected.not_to be_able_to(:create, report_cdl) }
      it { is_expected.not_to be_able_to(:update, report_cdl) }
      it { is_expected.not_to be_able_to(:destroy, report_cdl) }

      # it { is_expected.to be_able_to(:read, report_subset) }
      # it { is_expected.to be_able_to(:create, report_subset) }
      # it { is_expected.to be_able_to(:update, report_subset) }
      # it { is_expected.not_to be_able_to(:destroy, report_subset) }
    end
  end
end
