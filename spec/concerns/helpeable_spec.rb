
require 'rails_helper'

describe ReportsController, type: :request do

  describe 'permit_recursive_params' do

    context 'when the country counts are correct' do
      let(:params) { create(:report)}
  
      it "has correct country counts format" do
        y = params.attributes["report_datasets"].first["performance"].first["instance"].first
        x = ReportsController.permit_recursive_params y
        expect(x).to eq(["country", "access-method", "metric-type", "count"])
      end
    end
  end
end
