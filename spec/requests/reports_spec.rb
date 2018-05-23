require 'rails_helper'

describe 'Reports', type: :request do
  let(:bearer) { User.generate_token(client_id: "datacite.datacite", provider_id: "datacite", role_id: "staff_admin") }
  let(:headers) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer}}

  describe 'GET /reports' do
    let!(:reports)  { create_list(:report, 3) }

    context 'index' do
      before { get '/reports' }

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(3)
        expect(response).to have_http_status(200)
      end
    end
    context 'index filter by year' do
      let!(:report)  { create(:report, reporting_period:{"begin_date":"2222-01-01"}) }
      before { get '/reports?year=2222'}

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(1)
        expect(response).to have_http_status(200)
      end
    end
    context 'index filter by publisher' do
      let!(:report)  { create(:report, created_by:"Dash") }
      before { get '/reports?created-by=Dash' }

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(1)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /reports/:id' do
    let(:report)  { create(:report) }

    before { get "/reports/#{report.uid}", headers: headers }

    context 'when the record exists' do
      it 'returns the report' do
        puts json
        expect(json.dig("report","report-header", "report-id")).to eq(report.report_id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      before { get "/reports/0f8372ff-9bbb-44d0-80ff-a03f308f5889", headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to eq("status"=>"404", "title"=>"The resource you are looking for doesn't exist.")
      end
    end
  end

  describe 'POST /reports' do
    let(:params) {file_fixture('report_3.json').read}
    context 'when the request is valid' do
      before { post '/reports', params: params, headers: headers }

      it 'creates a report' do
        expect(json.dig("report", "report-header", "report-id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end
    end

    context 'index filter by client_id' do
      let!(:bearer_ext) { User.generate_token(client_id: "datacite.demo", provider_id: "datacite", role_id: "staff_admin") }
      let!(:headers_ext) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer_ext}}

      before { post '/reports', params: params, headers: headers_ext }

      it 'returns reports' do
        expect(json.dig("report", "report-header", "report-id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end

      after { get '/reports?client-id=datacite.demo' }

      it 'returns reports' do
        expect(json.dig("report", "report-header", "report-id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is valid has random schema' do
      let(:params) do
        { "report_header": {
          "report_name": "Dataset Report",
          "report_id": "DSR",
          "created": "2018-01-01",
          "reporting-period": {
            "begin-date": "2018-01-01",
            "end-date": "2022-01-01"
         },
          "report-filters": [],
          "report-attributes": [],
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
              "data-type": "dataset",
              "publisher": "DataONE",
              "dataset-title": "This is a dataset",
              "publisher-id": [
                  {
                  "type": "orcid",
                  "value": "0931-865-000-000"
                }
              ],
              "dataset_id": [
                {
                  "type": "doi",
                  "value": "0931-865"
                }
              ],
              "performance": [
                {
                  "period": {
                    "Begin-Date": "2018-03-01",
                    "End-Date": "2018-03-31"
                  },
                  "instance": [
                    {
                      "access-Method": "Regular",
                      "Metric-Type": "total-dataset-investigations",
                      "Count": 3
                    },
                    {
                      "Access-Method": "Regular",
                      "Metric-Type": "unique-dataset-investigations",
                      "Count": 3
                    }
                  ]
                }
              ]
            }
          ]
        }
      end
      before { post '/reports', params: params.to_json, headers: headers }

      it 'creates a report' do
        expect(json.dig("report", "report-header", "report-id")).to eq("DSR")
        expect(response).to have_http_status(201)
      end
    end

    context 'when the params is missing is required attirbutes' do
      let(:params) {file_fixture('report_4.json').read}
      before { post '/reports', params: params, headers: headers }

      it 'fails to create a report' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when the params is missing is dataset metrics' do
      let(:params) {file_fixture('report_5.json').read}
      before { post '/reports', params: params, headers: headers }

      it 'fails to create a report' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when the params keys are wrong' do
      let(:params) {file_fixture('report_6.json').read}
      before { post '/reports', params: params, headers: headers }

      it 'fails to create a report' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when the request is valid and has many countries' do
      let(:params_countries) {file_fixture('report_7.json').read}
      before { post '/reports', params: params_countries, headers: headers }

      it 'creates a report' do
        expect(response).to have_http_status(201)
        expect(json.dig("report", "report-header", "report-id")).to eq("FULL")
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
          "reporting-period": {
            "begin-date": "2018-01-01",
            "end-date": "2022-01-01"
         },
          "created_by": "CDL",
          "report-filters": [],
          "report-attributes": [],
        },
          "report_datasets": [
            {
              "yop": "2010",
              "platform": "DataONE",
              "data-type": "dataset",
              "publisher": "DataONE",
              "dataset-title": "This is a dataset",
              "publisher-id": [
                  {
                  "type": "orcid",
                  "value": "0931-865-000-000"
                }
              ],
              "dataset_id": [
                {
                  "type": "DOI",
                  "value": "0931-865"
                }
              ],
              "performance": [
                {
                  "period": {
                    "Begin-Date": "2018-03-01",
                    "End-Date": "2018-03-31"
                  },
                  "instance": [
                    {
                      "access-Method": "Regular",
                      "Metric-Type": "total-dataset-investigations",
                      "Count": 3
                    },
                    {
                      "Access-Method": "Regular",
                      "Metric-Type": "unique-dataset-investigations",
                      "Count": 3
                    }
                  ]
                }
              ]
            }
          ]
        }
      end
      before { put "/reports/#{report.uid}", params: params.to_json, headers: headers }
  
      it 'updates the record' do
        expect(json.dig('report', 'report-header', 'created-by')).to eq("CDL")
        expect(response).to have_http_status(200)
      end
    end
  

    context 'when the request is invalid' do
      let(:params) do
        { "report_heasder": {
          "report_name": "Dataset Report",
          "created": "2018-01-01",
          "reporting-period": {
            "begin-date": "2018-01-01",
            "end-date": "2022-01-01"
         },
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


    context "updating report-header" do
      let!(:uid) { SecureRandom.uuid  }
      let(:params) {file_fixture('report_3.json').read}
      let(:params_update) {file_fixture('report_9.json').read}

      before { put "/reports/#{uid}", params: params, headers: headers }
      before { put "/reports/#{uid}", params: params_update, headers: headers }
      before { get "/reports/#{uid}", headers: headers }


      it "it should not update" do
        expect(response).to have_http_status(200)
        expect(json["errors"]).to be_nil
        expect(json.dig("report", "id")).to eq(uid)
        expect(json.dig("report", "report-header", "created-by")).to eq("dash")
        expect(json.dig("report", "report-header", "reporting-period", "begin-date")).not_to eq("2129-05-09")
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
      before { delete '/reports/0f8372ff-9bbb-44d0-80ff-a03f308f5889', headers: headers }
  
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to eq("status"=>"404", "title"=>"The resource you are looking for doesn't exist.")
      end
    end
  end
  


  describe "UPSERT /reports/:id" do
    let!(:uid) { SecureRandom.uuid  }
    let(:uri) { "/reports/#{uid}" }
    let(:params) {file_fixture('report_7.json').read}

    context "as admin user" do

      before { put "/reports/#{uid}", params: params, headers: headers }


      it "it should create a report" do

        expect(response).to have_http_status(201)
        expect(json["errors"]).to be_nil
        expect(json.dig("report", "id")).to eq(uid)
        expect(json.dig("report", "report-header", "created-by")).to eq("Dash")
      end
    end


    context "entry already exists with other uuid" do
      # let!(:report) { create(:report) }
      let!(:uid) { SecureRandom.uuid  }
      let!(:second_uid) { SecureRandom.uuid  }
      let(:params_update) {file_fixture('report_8.json').read}

 
      before { put "/reports/#{uid}", params: params, headers: headers }

      before { put "/reports/#{second_uid}", params: params, headers: headers }

      it "should fail update report" do

        expect(response).to have_http_status(409)
        expect(json["report"]).to be_nil
        expect(json["errors"].first).to eq("status"=>"409", "title"=>"The resource already exists.")
      end
    end


    context "entry already exists" do
      let!(:uid) { SecureRandom.uuid  }
      let(:params_update) {file_fixture('report_8.json').read}

 
      before { put "/reports/#{uid}", params: params, headers: headers }

      before { put "/reports/#{uid}", params: params_update, headers: headers }

      it "should update report" do

        expect(response).to have_http_status(200)

        expect(json["errors"]).to be_nil
        expect(json.dig("report", "id")).to eq(uid)
        expect(json.dig("report", "report-header", "release")).to eq("rd2")
      end
    end
  end


end
