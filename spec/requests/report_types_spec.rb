require 'rails_helper'

describe 'ReportTypes', type: :request do
  let(:bearer) { User.generate_token(uid: "datacite.datacite", role_id: "staff_admin") }
  let(:headers) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer}}

  # describe 'GET /reports' do
  #   let!(:report_type)  { {report_type: "Master_report"} }

  #   context 'index' do
  #     before { get '/report-types' }

  #     it 'returns reports' do
  #       expect(json).not_to be_empty
  #       expect(json['report-types'].size).to eq(1)
  #       expect(response).to have_http_status(200)
  #     end
  #   end
  # end

  # describe 'GET /report-types/:id' do
  #   let(:report)  { create(:report) }

  #   before { get "/report-types/#{report.uid}", headers: headers }

  #   context 'when the record exists' do
  #     it 'returns the report' do
  #       puts json
  #       expect(json.dig("report","report-header", "report-id")).to eq(report.report_id)
  #       expect(response).to have_http_status(200)
  #     end
  #   end

  #   context 'when the record does not exist' do
  #     before { get "/report-types/0f8372ff-9bbb-44d0-80ff-a03f308f5889", headers: headers }

  #     it 'returns status code 404' do
  #       expect(response).to have_http_status(404)
  #       expect(json["errors"].first).to eq("status"=>"404", "title"=>"The resource you are looking for doesn't exist.")
  #     end
  #   end
  # end

  # describe 'POST /report-types' do
  #   let!(:params)  { {"report-id": "Master_report"}} 
  #   context 'when the request is valid' do
  #     before { post '/report-types', params: params.to_json, headers: headers }

  #     it 'creates a report' do
  #       puts json
  #       expect(response).to have_http_status(201)
  #       expect(json.dig("report_id")).to eq("Master_report")
  #     end
  #   end
  # end
end
