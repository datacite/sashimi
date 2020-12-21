require 'rails_helper'
require 'json-schema'
require 'fileutils'
require 'json' 

describe Report, type: :model do
  let!(:report) { create(:report) }
  let(:usage_schema) { File.read("lib/sushi_schema/sushi_usage_schema.json") }
  let(:res_schema) { File.read("lib/sushi_schema/sushi_resolution_schema.json") }
  let(:reso) do
    [{
      "dataset-id": [{
          "type": "doi",
          "value": "10.5072/0931-865"
      }],
      "performance": [
        {
          "period": {
            "begin-date": "2018-03-01",
            "end-date": "2018-03-31"
          },
          "instance": [
            {
              "access-method": "regular",
              "metric-type": "total-resolutions",
              "count": 3
            },
            {
              "access-method": "regular",
              "metric-type": "unique-resolutions",
              "count": 3
            }
          ]
        }
      ]
    }]
  end

  describe 'Report schema validation' do
    context 'when the schema is correct' do
      subject { report }

      it "has correct sushi format" do
        payload = subject.is_valid_sushi?
        expect(payload).to eq(true)
      end

      it "validate_sushi" do
        payload = subject.validate_sushi   
        expect(payload).to be_empty
      end

      # it "checks stuff" do
      #   file = File.read('/home/app/webapp/spec/fixtures/files/report_3.json')
      #   schema = (File.read("/home/app/webapp/spec/fixtures/files/sushi_schema.json"))        
      #   valid =  JSON::Validator.fully_validate(schema, file, :errors_as_objects => true)
      #   expect(valid).to be_empty
      # end
    end

    context 'when the schema is incorrect' do
      # subject { create(:report, report_datasets: ["hola"]) }
      # it "has correct sushi format" do
      #   payload = subject.is_valid_sushi? 
      #   expect(payload).to eq(false)
      # end

      # it "validate_sushi" do
      #   payload = subject.validate_sushi
        
      #   expect(payload).not_to be_empty
      # end

      # it "checks stuff" do
      #   file = File.read('/home/app/webapp/spec/fixtures/files/report_4.json')
      #   schema = (File.read("/home/app/webapp/spec/fixtures/files/sushi_schema.json"))        
      #   valid =  JSON::Validator.fully_validate(schema, file, :errors_as_objects => true)
      #   expect(valid).not_to be_empty
      # end
    end
  end

  describe "validate_this_sushi" do
    let(:report_drl) {create(:report, release: "drl", report_datasets: reso)}
    let(:report_drl_hsh) {build(:report, release: "drl", report_datasets: reso)}
    let(:report_rd1) {create(:report, release: "rd1")}
    let(:report_rd1_hsh) {build(:report, release: "rd1")}
    let(:report_xx) {create(:report, release: "ccc")}

    context "validate_this_sushi as Subset" do
      let(:drl) {create(:report_subset, report_id: report_drl.uid)}
      let(:rd1) {create(:report_subset, report_id: report_rd1.uid)}
      let(:xx)  {create(:report_subset, report_id: report_xx.uid)}

      it "should load drl" do
        report = report_drl_hsh.attributes.except("compressed")
        report.transform_keys! { |key| key.tr('_', '-') }
        validation = drl.validate_this_sushi report
        expect(validation).to be_empty
      end

      it "should load rd1" do
        report = report_rd1_hsh.attributes.except("compressed")
        report.transform_keys! { |key| key.tr('_', '-') }
        validation = rd1.validate_this_sushi report
        expect(validation).to be_empty
      end

      # it "should sent error" do
      #   schema = xx.load_schema
      #   expect(schema).to eq({})
      # end

      it "should send error if mixed" do
        report = report_rd1_hsh.attributes.except("compressed")
        report.transform_keys! { |key| key.tr('_', '-') }
        validation = drl.validate_this_sushi(report)
        expect(validation).to be_a(Array)
      end
    end
  end

  describe "load_schema" do
    let(:report_drl) {create(:report, release: "drl", report_datasets: reso)}
    let(:report_rd1) {create(:report, release: "rd1")}
    let(:report_xx) {create(:report, release: "ccc")}

    context "load_schema as Subset" do
      let(:drl) {create(:report_subset, report_id: report_drl.uid)}
      let(:rd1) {create(:report_subset, report_id: report_rd1.uid)}
      let(:xx)  {create(:report_subset, report_id: report_xx.uid)}
      
      it "should load drl" do
        schema = drl.load_schema
        expect(schema).to eq(res_schema)
      end

      it "should load rd1" do
        schema = rd1.load_schema
        expect(schema).to eq(usage_schema)
      end

      it "should sent error" do
        schema = xx.load_schema
        expect(schema).to eq({})
      end

      it "should sent error if mixed" do
        schema = rd1.load_schema
        expect(schema).not_to eq(res_schema)
      end
    end

    context "load_schema as Report" do
      it "should load drl" do
        schema = report_drl.load_schema
        expect(schema).to eq(res_schema)
      end

      it "should load rd1" do
        schema = report_rd1.load_schema
        expect(schema).to eq(usage_schema)
      end

      it "should sent error" do
        schema = report_xx.load_schema
        expect(schema).to eq({})
      end
    end
  end
end
