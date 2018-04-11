require 'rails_helper'
require 'json-schema'
require 'fileutils'
require 'json' 
describe Report, type: :model do
  let!(:report) { create(:report) }

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
      subject { create(:report, report_filters: "hola") }
      # it "has correct sushi format" do
      #   payload = subject.is_valid_sushi? 
      #   expect(payload).to eq(false)
      #     end

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
end
