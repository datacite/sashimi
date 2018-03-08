require 'rails_helper'

describe User, type: :model do
  describe "from token" do
    let(:token) { User.generate_token }
    let(:user) { User.new(token) }

    describe 'User attributes' do
      it "has role_id" do
        expect(user.role_id).to eq("staff_admin")
      end

      it "has name" do
        expect(user.name).to eq("Josiah Carberry")
      end
    end
  end
end
