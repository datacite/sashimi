require 'rails_helper'

describe 'Reports', type: :request do
  let(:bearer) { User.generate_token(client_id: "datacite.datacite", provider_id: "datacite", role_id: "client_admin") }
  let(:headers) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer}}

  describe 'GET /reports' do
    let!(:report)  { create_list(:report, 3) }

    before { get '/reports', headers: headers }

    it 'returns reports' do
      expect(json).not_to be_empty
      expect(json['reports'].size).to eq(3)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /reports/:id' do
    let(:report)  { create(:report) }

    before { get "/reports/#{report.uid}", headers: headers }

    context 'when the record exists' do
      it 'returns the report' do
        expect(json.dig("report","report_header", "report_id")).to eq(report.report_id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      before { get "/reports/xxx", headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to eq("status"=>"404", "title"=>"The resource you are looking for doesn't exist.")
      end
    end
  end

  describe 'POST /reports' do
    let(:params) do
      { "report_header": {
        "report_name": "Dataset Report",
        "report_id": "DSR",
        "created": "2018-01-01",
        "created_by": "CDL"
      },
        "report_datasets": [
          {
            "yop": "2010",
            "platform": "DataONE",
            "data_type": "Dataset",
            "publisher": "DataONE",
            "dataset_id": [
              {
                "type": "DOI",
                "value": "0931-865"
              }
            ]
          }
        ]
      }
    end

    context 'when the request is valid' do
      before { post '/reports', params: params.to_json, headers: headers }

      it 'creates a report' do
        expect(json.dig("report", "report_header", "report_id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is valid has random schema' do
      let(:params) do
        { "report_header": {
          "report_name": "Dataset Report",
          "report_id": "DSR",
          "created": "2018-01-01",
          "exceptions": [
            {
              "code": 3040,
              "Severity": "Warning",
              "Message": "Partial Data Returned",
              "Help-URL": "String",
              "Data": "Usage data has not been processed for the entire reporting period"
            }
          ],
          "created_by": "CDL"
        },
          "report_datasets": [
            {
              "yop": "2010",
              "platform": "DataONE",
              "data_type": "Dataset",
              "publisher": "DataONE",
              "dataset_id": [
                {
                  "type": "DOI",
                  "value": "0931-865"
                }
              ]
            }
          ]
        }
      end
      before { post '/reports', params: params.to_json, headers: headers }

      it 'creates a report' do
        puts json
        expect(json.dig("report", "report_header", "report_id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end
    end
  end


  describe 'PUT /reports/:id' do
    let!(:report)  { create(:report) }

    context 'when the record exists' do
      let(:params) do
        { "report_header": {
          "report_name": "Dataset Report",
          "report_id": "DSR",
          "created": "2018-01-01",
          "created_by": "CDL"
        },
          "report_datasets": [
            {
              "yop": "2010",
              "platform": "DataONE",
              "data_type": "Dataset",
              "publisher": "DataONE",
              "dataset_id": [
                {
                  "type": "DOI",
                  "value": "0931-865"
                }
              ]
            }
          ]
        }
      end
      before { put "/reports/#{report.uid}", params: params.to_json, headers: headers }
  
      it 'updates the record' do
        expect(json.dig('report', 'report_header', 'created_by')).to eq("CDL")
        expect(response).to have_http_status(200)
      end
    end
  

    context 'when the request is invalid' do
      let(:params) do
        { "report_heasder": {
          "report_name": "Dataset Report",
          "created": "2018-01-01",
          "report_id": "DSR",
        },
          "report_datasets": [
            {
              "yop": "2010",
              "platform": "DataONE",
              "data_type": "Dataset",
              "publisher": "DataONE",
              "dataset_id": [
                {
                  "type": "DOI",
                  "value": "0931-865"
                }
              ]
            }
          ]
        }
      end
  
      before { put "/reports/#{report.uid}", params: params.to_json, headers: headers }
  
      it 'returns status code 422' do
        expect(response).to have_http_status(422)
        expect(json["errors"].first).to eq("status"=>"422", "title"=>"You need to provide a payload following the SUSHI specification")
      end
    end
  end
  # Test suite for DELETE /reports/:id
  describe 'DELETE /reports/:id' do
    let!(:report)  { create(:report) }

    before { delete "/reports/#{report.uid}", headers: headers }
  
    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  
    context 'when the resources doesnt exist' do
      before { delete '/reports/xxx', headers: headers }
  
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to eq("status"=>"404", "title"=>"The resource you are looking for doesn't exist.")
      end
    end
  end
  
end
