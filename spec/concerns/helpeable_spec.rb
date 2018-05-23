
require 'rails_helper'

describe ReportsController, type: :request do

  describe 'permit_recursive_params' do

    context 'when the country counts are correct' do
      let(:params) { create(:report)}
  
      it "has correct country counts format" do
        y = params.attributes["report_datasets"].first["performance"].first["instance"].first
        x = ReportsController.permit_recursive_params y
        expect(x).to eq(["access-method", "metric-type", "count"])
      end
    end
  end

  class FakesController < ApplicationController
    include Helpeable
  end

  describe 'validate uuid' do
  
    it "should pass when id is uuid" do
      response = subject.validate_uuid SecureRandom.uuid
      expect(response).to be true
    end

    it "should pass when id is uuid" do
      response = subject.validate_uuid SecureRandom.uuid.upcase
      expect(response).to be true
    end

    it "shoudl fail when id is just a string" do
      response = subject.validate_uuid "ddds-44ss-sdsd44"
      expect(response).to be_nil
    end
  end
end


