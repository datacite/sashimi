require 'rails_helper'

describe 'Reports', type: :request do
  let(:bearer) { User.generate_token(exp:Time.now.to_i+300,client_id: "datacite.datacite", provider_id: "datacite", role_id: "staff_admin") }
  let(:headers) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer}}

  describe 'GET /reports' do
    let!(:reports)  { create_list(:report, 3, compressed: nil) }

    context 'index' do
      before { get '/reports' }

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(3)
        expect(response).to have_http_status(200)
      end
    end
    context 'index filter by year' do
      let!(:report)  { create(:report, reporting_period:{"begin_date":"2222-01-01"}, compressed: nil) }
      before { get '/reports?year=2222'}

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(1)
        expect(response).to have_http_status(200)
      end
    end
    context 'index filter by publisher' do
      let!(:report)  { create(:report, created_by:"Dash", compressed: nil) }
      before { get '/reports?created-by=Dash' }

      it 'returns reports' do
        expect(json).not_to be_empty
        expect(json['reports'].size).to eq(1)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /reports/:id' do
    let(:report)  { create(:report, compressed: nil) }

    before { get "/reports/#{report.uid}", headers: headers }

    context 'when the record exists' do
      it 'returns the report' do
        #puts json
        expect(json.dig("report","report-header", "report-name")).to eq(report.report_name)
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
        #puts json
        expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
        expect(response).to have_http_status(201)
      end
    end

    # commented because it takes too long
    # context 'when the params is large' do
    #   let(:params) {file_fixture('large_file.json').read}
    #   before { post '/reports', params: params, headers: headers }

    #   it 'succed large file to create a report' do
    #     expect(response).to have_http_status(201)
    #   end
    # end

    context 'when the request is valid but another report from the same month exist' do
      let(:params) {file_fixture('report_3.json').read}
      let(:params_repeat) {file_fixture('report_repeat.json').read}
 
      before { post '/reports', params: params, headers: headers}
      before { post '/reports', params: params_repeat, headers: headers}

      it 'fails to create a report' do
        #puts json
        expect(json.dig("report", "report-header", "created")).to eq("2128-04-09")
        expect(json.dig("report", "report-datasets", 0, "dataset-title")).to eq("chemical shift-based methods in nmr structure determination")
        expect(response).to have_http_status(201)
      end
    end

    context 'index filter by client_id' do
      let!(:bearer_ext) { User.generate_token(client_id: "datacite.demo", provider_id: "datacite", role_id: "staff_admin") }
      let!(:headers_ext) { {'ACCEPT'=>'application/json', 'CONTENT_TYPE'=>'application/json', 'Authorization' => 'Bearer ' + bearer_ext}}

      before { post '/reports', params: params, headers: headers_ext }

      it 'returns reports' do
        expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
        expect(response).to have_http_status(201)
      end

      after { get '/reports?client-id=datacite.demo' }

      it 'returns reports' do
        expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is valid has random schema' do
      let(:params) do
        { "report_header": {
          "report_name": "Dataset Report",
          "report_id": "DSR",
          "release": "rd1",
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
              "dataset-id": [
                {
                  "type": "doi",
                  "value": "0931-865"
                }
              ],
              "performance": [
                {
                  "period": {
                    "begin-date": "2018-03-01",
                    "end-date": "2018-03-31"
                  },
                  "instance": [
                    {
                      "access-method": "regular",
                      "metric-type": "total-dataset-investigations",
                      "count": 3
                    },
                    {
                      "access-method": "regular",
                      "metric-type": "unique-dataset-investigations",
                      "count": 3
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
        #puts json
        expect(json.dig("report", "report-header", "report-name")).to eq("Dataset Report")
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

    # context 'wwhen the body has no header' do
    #   let(:params) {file_fixture('report_10.json').read}
    #   before { post '/reports', params: params, headers: headers }

    #   it 'create a report' do
    #     puts response
    #     #puts json

    #     expect(response).to have_http_status(201)
    #     expect(json.dig("report", "report-header", "report-name")).to eq("SatanCruz")
    #   end
    # end

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
        expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
      end
    end
  end


  describe 'PUT /reports/:id' do
    let!(:report)  { create(:report) }

    context 'when the record exists' do
      let(:params) do
        { "report-header": {
          "report-name": "Dataset Report",
          "report-id": "DSR",
          "release": "rd1",
          "created": "2018-01-01",
          "reporting-period": {
            "begin-date": "2018-01-01",
            "end-date": "2022-01-01"
         },
          "created-by": "CDL",
          "report-filters": [],
          "report-attributes": [],
        },
          "report-datasets": [
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
              "dataset-id": [
                {
                  "type": "DOI",
                  "value": "0931-865"
                }
              ],
              "performance": [
                {
                  "period": {
                    "begin-date": "2018-03-01",
                    "end-date": "2018-03-31"
                  },
                  "instance": [
                    {
                      "access-method": "regular",
                      "metric-type": "total-dataset-investigations",
                      "count": 3
                    },
                    {
                      "access-method": "regular",
                      "metric-type": "unique-dataset-investigations",
                      "count": 3
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
        #puts json
        expect(json.dig('report', 'report-header', 'created-by')).to eq("CDL")
        expect(response).to have_http_status(200)
      end
    end
  
    # context 'when the request is valid and compressed with small file' do
    #   let(:bigly)       {create(:report, created_by: "dash", release: "rd1", reporting_period: {"begin_date": "2128-04-01", "end_date": "2128-04-31" })}
    #   let(:update_file) {file_fixture('report_compressed.json').read}

    #   let(:headers)  { {
    #     'Content-Type' => 'application/gzip',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'json',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }

    #   let(:second_gzip) do
    #     ActiveSupport::Gzip.compress(update_file)
    #   end
  
    #   before do
    #     put "/reports/#{bigly.uid}", params: second_gzip, headers: headers 
    #   end

    #   it 'creates a report' do
    #     report = Report.where(uid:bigly.uid).first
    #     expect(json.dig("report", "report-header", "report-name")).to eq(report.report_name)
    #     expect(json.dig("report","report-datasets")).to eq(report.report_datasets)
    #     expect(json.dig("report","report-datasets",0,"checksum")).not_to be_nil
    #   end

    #   it 'checksum doesnt fail' do
    #     report_checksum = json.dig("report", "checkum")
    #     gzip_2 = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip_2)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end

    context 'when the request is invalid' do
      let(:params) do
        { "report_heasder": {
          "report_name": "Dataset Report",
          "created": "2018-01-01",
          "release": "rd1",
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
  
      it 'returns status code 400' do
        expect(response).to have_http_status(400)
        # expect(json["errors"].first).to eq("status"=>"422", "title"=>"You need to provide a payload following the SUSHI specification")
      end
    end


    context "updating report-header" do
      let!(:uid) { SecureRandom.uuid  }
      let(:params) {file_fixture('report_3.json').read}
      let(:params_update) {file_fixture('report_9.json').read}

      before do 
        put "/reports/#{uid}", params: params, headers: headers 
        put "/reports/#{uid}", params: params_update, headers: headers 
        sleep 1 
        get "/reports/#{uid}", headers: headers 
      end

      
      it "it shoud not change db" do
        report = Report.where(uid: uid ).first
        date = json.dig("report", "report-header", "reporting-period", "begin-date")
        expect(Date.parse(date).month.to_s).to eq(report.month)
        expect(Date.parse(date).year.to_s).to eq(report.year)
        expect(json.dig("report", "report-header", "created-by")).to eq(report.created_by)
      end
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
        #puts json
        expect(response).to have_http_status(201)
        expect(json["errors"]).to be_nil
        expect(json.dig("report", "id")).to eq(uid)
        expect(json.dig("report", "report-header", "created-by")).to eq("dash")
      end
    end


    context "entry already exists with other uuid" do
      # let!(:report) { create(:report) }
      let!(:uid) { SecureRandom.uuid  }
      let!(:second_uid) { SecureRandom.uuid  }
      let(:params_update) {file_fixture('report_8.json').read}

 
      before { put "/reports/#{uid}", params: params_update, headers: headers }

      before { put "/reports/#{second_uid}", params: params_update, headers: headers }

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
        expect(json.dig("report", "report-header", "release")).to eq("rd1")
      end
    end
  end

#   describe "IRUS-UK report" do
#   let(:params) {file_fixture('irus_uk.json').read}

#   context 'when the request is valid' do
#     before { post '/reports', params: params, headers: headers }

#     it 'creates a report' do
#       expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
#       expect(response).to have_http_status(201)
#     end
#   end
# end

  describe "Compressed Reports" do
    let(:bigly) {file_fixture('small_dataone.json').read}

    let(:headers)  { {
      'Content-Type' => 'application/gzip',
      'Content-Encoding' => 'gzip',
      'Authorization' => 'Bearer ' + bearer
    } }
    let(:gzipped) do
      ActiveSupport::Gzip.compress(bigly)
    end    

    describe 'add subset to report' do


      context 'when the report exist' do
        # let(:dataone) {file_fixture('small_dataone.json').read}
                
        before do
          post '/reports', params: gzipped, headers: headers 
          sleep 1
          post '/reports', params: gzipped, headers: headers 
        end
        
        it 'should return 201'do
          datasets = json.dig("report","report-subsets")
   
          expect(datasets).to be_a(Array)
          expect(datasets.size).to eq(2)
          expect(datasets.dig(1,"gzip")).to be_a(String)
          expect(datasets.dig(1,"checksum")).to be_a(String)
          expect(response).to have_http_status(201)
        end
        it 'should add subsets' do
          uid = json.dig("report","id")
          report = Report.where(uid: uid ).first
          expect(report.report_subsets.size).to eq(2)
          expect(report.report_subsets.first.report_id).to eq(uid)
        end
      end
      context 'when the report doesnt exist' do
        # let(:dataone) {file_fixture('small_dataone.json').read}

        before { post '/reports', params: gzipped, headers: headers }
        
        it 'should return 201' do
          puts json
          datasets = json.dig("report","report-subsets")
          expect(datasets).to be_a(Array)
          expect(datasets.size).to eq(1)
          expect(datasets.dig(0,"gzip")).to be_a(String)
          expect(response).to have_http_status(201)
        end
        it 'should add subsets' do
          uid = json.dig("report","id")
          report = Report.where(uid: uid ).first
          expect(report.report_subsets.size).to eq(1)
          expect(report.report_subsets.first.report_id).to eq(uid)
        end
      end
    end

    describe 'update compressed report' do

      context 'when the report exist' do

        before do
          post '/reports', params: gzipped, headers: headers 
          post '/reports', params: gzipped, headers: headers 
          post '/reports', params: gzipped, headers: headers 
          put "/reports/#{json.dig("report","id")}", params: gzipped, headers: headers 
        end

        it 'should return 200 and clear all other reports'do

          datasets = json.dig("report","report-subsets")
          puts json
          expect(datasets).to be_a(Array)
          expect(datasets.size).to eq(1)
          expect(datasets.dig(0,"gzip")).to be_a(String)
          expect(response).to have_http_status(200)
        end

        it 'should add subsets' do
          uid = json.dig("report","id")
          report = Report.where(uid: uid ).first
          expect(report.report_subsets.size).to eq(1)
          expect(report.report_subsets.first.report_id).to eq(uid)
        end
      end
      context 'when the report doesnt exist' do
        # let(:dataone) {file_fixture('small_dataone.json').read}

        before do
           put "/reports/0b04a368-989b-405b-a382-a85ce558df40", params: gzipped, headers: headers 
        end

        it 'should return 201' do
          puts json
          datasets = json.dig("report","report-subsets")
          expect(datasets).to be_a(Array)
          expect(datasets.size).to eq(1)
          expect(datasets.dig(0,"gzip")).to be_a(String)
          expect(response).to have_http_status(201)
        end
        it 'should add subsets' do
          uid = json.dig("report","id")
          report = Report.where(uid: uid ).first
          expect(report.report_subsets.size).to eq(1)
        end
      end
    end

    describe 'delete compressed report' do
      context 'when the report exist' do

        before do
          post '/reports', params: gzipped, headers: headers 
          delete "/reports/#{json.dig("report","id")}", headers: headers 
        end

        it 'should return 204 and clear all other reports' do
          expect(response).to have_http_status(204)
        end
        # it 'should remove subsets' do
        #   uid =   json.dig("report","id")
        #   report = Report.where(uid: uid ).first
        #   expect(report.report_subsets.empty?).to eq(true)
        # end
      end
      context 'when the report doesnt exist' do

        before { delete '/reports/0b04a368-989b-405b-a382-a85ce558df56', headers: headers }

        it 'should return 204 and create report'do
          expect(response).to have_http_status(404)
        end
      end
    end



    # context 'Resolution when the request is valid' do
    #   let(:resolutions) {file_fixture('report_resolution.json').read}
    #   let(:headers)  { {
    #     'Content-Type' => 'application/gzip',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'gzip',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }
    #   let(:gzip) do
    #     ActiveSupport::Gzip.compress(resolutions)
    #   end
    #   before { post '/reports', params: gzip, headers: headers }

    #   it 'creates a Resolution report' do
    #     #puts json
    #     expect(json.dig("report", "report-header", "report-name")).to eq("resolution report")
    #     expect(json.dig("report", "report-header", "release")).to eq("drl")
    #     expect(response).to have_http_status(201)
    #   end

    #   it 'decodes correctly' do
    #     gzip_3 = Base64.decode64(json.dig("report", "gzip"))
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     expect(gzip_3).to eq(report.compressed)
    #   end

    #   it 'decrompress correctly' do
    #     # puts resolutions
    #     parser = Yajl::Parser.new
    #     gzip_2 = Base64.decode64(json.dig("report", "gzip"))
    #     fjson = parser.parse(ActiveSupport::Gzip.decompress(gzip_2))
    #     expect(fjson.dig("report-datasets",0,"yop")).to eq("2017")
    #     expect(fjson.dig("report-datasets",0,"platform")).to eq("datacite")
    #     expect(fjson.dig("report-datasets").length).to eq(34)
    #   end

    #   it 'checksum doesnt fail' do
    #     report_checksum = json.dig("report", "checkum")
    #     gzip_2 = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip_2)
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     original_checksum = report.checksum
    #     expect(report_checksum).eql?(original_checksum)
    #     expect(original_checksum).eql?(decode_checksum)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end

    # context 'when acces_method not in the insatnce' do
    #   let(:dataone) {file_fixture('DSR-D1-2012-07-10.json').read}
    #   before { post '/reports', params: dataone, headers: headers }

    #   it 'fail to create' do
    #     #puts json
    #     expect(json.dig("errors",0, "title")).to eq("found unpermitted parameter: :access-method")
    #     expect(response).to have_http_status(422)
    #   end
    # end

    # context 'when the request is valid and compressed with small file without message' do
    #   let(:bigly) {file_fixture('report_compressed.json').read}

    #   let(:headers)  { {
    #     'Content-Type' => 'json',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'json',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }
    #   let(:gzip) do
    #     ActiveSupport::Gzip.compress(bigly)
    #   end
  
    #   before { post '/reports', params: gzip, headers: headers }

    #   it 'creates a report' do
    #     expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
    #     expect(json.dig("report","report-datasets",0,"empty")).to eq("too large")
    #     expect(json.dig("report","report-datasets",0,"checksum")).not_to be_nil
    #   end

    #   it 'decodes correctly' do
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     expect(gzip).to eq(report.compressed)
    #   end

    #   it 'decrompress correctly' do
    #     parser = Yajl::Parser.new
    #     gzip_2 = Base64.decode64(json.dig("report", "gzip"))
    #     puts ActiveSupport::Gzip.decompress(gzip_2)
    #     fjson = parser.parse(ActiveSupport::Gzip.decompress(gzip_2))
    #     expect(fjson.dig("report-header", "report-name")).to eq("dataset report")
    #     expect(fjson.dig("report-datasets",0,"yop")).to eq("2018")
    #     expect(fjson.dig("report-datasets").length).to eq(1)
    #     expect(fjson.dig("report-datasets",0,"dataset-title")).to eq("chemical shift-based methods in nmr structure determination")
    #   end

    #   it 'checksum doesnt fail' do
    #     report_checksum = json.dig("report", "checkum")
    #     gzip_2 = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip_2)
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     original_checksum = report.checksum
    #     expect(report_checksum).eql?(original_checksum)
    #     expect(original_checksum).eql?(decode_checksum)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end

    



    # context 'when the request is valid and compressed but not very large file' do
    #   let(:bigly) {file_fixture('large_file_lc_2.json').read}

    #   let(:headers)  { {
    #     'Content-Type' => 'json',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'json',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }
    #   let(:gzip) do
    #     ActiveSupport::Gzip.compress(bigly)
    #   end
  
    #   before { post '/reports', params: gzip, headers: headers }

    #   it 'creates a report' do
    #     expect(json.dig("report", "report-header", "report-name")).to eq("dataset report")
    #     expect(json.dig("report","report-datasets","empty")).to eq("too large")
    #     expect(json.dig("report","report-datasets","checksum")).not_to be_nil
    #   end

    #   it 'decodes correctly' do
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     expect(gzip).to eq(report.compressed)
    #   end

    #   # it 'decrompress correctly' do
    #   #   parser = Yajl::Parser.new
    #   #   gzip = Base64.decode64(json.dig("report", "gzip"))
    #   #   puts ActiveSupport::Gzip.decompress(gzip)
    #   #   fjson = parser.parse(ActiveSupport::Gzip.decompress(gzip))
    #   #   expect(fjson.dig("report-header", "report-name")).to eq("dataset report")
    #   #   expect(fjson.dig("report-datasets",0,"dataset-title")).to eq("chemical shift-based methods in nmr structure determination")
    #   #   expect(fjson.dig("report-datasets",0,"yop")).to eq("2018")
    #   #   expect(fjson.dig("report-datasets").length).to eq(1)
    #   # end

    #   it 'checksum doesnt fail' do
    #     report_checksum = json.dig("report", "checkum")
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip)
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     original_checksum = report.checksum
    #     expect(report_checksum).eql?(original_checksum)
    #     expect(original_checksum).eql?(decode_checksum)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end
    # context 'when the request is valid and compressed very large file' do
    #   # let(:bigly) {file_fixture('datacite_resolution_report_2018-04.json').read}
    #   let(:bigly) {file_fixture('DSR-D1-2012-08-01-urn-node-PISCO_2.json').read}

    #   let(:headers)  { {
    #     'Content-Type' => 'json',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'json',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }
    #   let(:gzip) do
    #     ActiveSupport::Gzip.compress(bigly)
    #   end
  
    #   before { post '/reports', params: gzip, headers: headers }

    #   it 'creates a report' do
    #     # puts gzip
    #     # puts response.inspect
    #     File.open("./spec/pisco_compress.json", 'w') { |file| file.write(json) }
    #     # puts response
    #     # puts 
    #     expect(json.dig("report", "report-header", "report-name")).to eq("dataset master report")
    #     expect(json.dig("report","report-datasets","empty")).to eq("too large")
    #     # expect(json.dig("report","report-datasets","checksum")).not_to be_nil
    #     expect(response).to have_http_status(201)
    #   end

    #   it 'decodes correctly and checksums' do
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     expect(gzip).to eq(report.compressed)

    #     report_checksum = json.dig("report", "checkum")
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip)
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     original_checksum = report.checksum
    #     expect(report_checksum).eql?(original_checksum)
    #     expect(original_checksum).eql?(decode_checksum)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end

    # context 'when the request is valid and compressed very large file resolution file' do
    #   let(:bigly) {file_fixture('datacite_resolution_report_2018-04.json').read}

    #   let(:headers)  { {
    #     'Content-Type' => 'json',
    #     'Content-Encoding' => 'gzip',
    #     'ACCEPT'=>'json',
    #     'Authorization' => 'Bearer ' + bearer
    #   } }
    #   let(:gzip) do
    #     ActiveSupport::Gzip.compress(bigly)
    #   end
  
    #   before { post '/reports', params: gzip, headers: headers }

    #   it 'creates a report' do
    #     # puts gzip
    #     # puts response.inspect
    #     File.open("./spec/resolution_compress.json", 'w') { |file| file.write(json.to_json) }
    #     # puts response
    #     # puts 
    #     expect(json.dig("report", "report-header", "report-name")).to eq("resolution report")
    #     expect(json.dig("report","report-datasets","empty")).to eq("too large")
    #     expect(response).to have_http_status(201)
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     expect(gzip).to eq(report.compressed)

    #     report_checksum = json.dig("report", "checkum")
    #     gzip = Base64.decode64(json.dig("report", "gzip"))
    #     decode_checksum = Digest::SHA256.hexdigest(gzip)
    #     report = Report.where(uid:json.dig("report", "report-header","report-id")).first
    #     original_checksum = report.checksum
    #     expect(report_checksum).eql?(original_checksum)
    #     expect(original_checksum).eql?(decode_checksum)
    #     expect(report_checksum).eql?(decode_checksum)
    #   end
    # end

  end

end
