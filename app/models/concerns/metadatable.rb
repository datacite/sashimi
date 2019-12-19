module Metadatable
  extend ActiveSupport::Concern

  require 'json-schema'
  require 'fileutils'
  require 'json' 

  included do
    def validate_sushi 
      schema = load_schema
      report = self.attributes.except("compressed")
      report.transform_keys! { |key| key.tr('_', '-') }
   
      JSON::Validator.fully_validate(schema, report.to_json, :errors_as_objects => true)
    end

    def validate_this_sushi(sushi)
      schema = load_schema 
      JSON::Validator.fully_validate(schema, sushi.to_json, :errors_as_objects => true)
    end

    def validate_this_sushi_with_error(sushi)
      schema = load_schema 
      JSON::Validator.validate!(schema, sushi.to_json)
    rescue JSON::Schema::ValidationError => exception
      Raven.capture_exception(exception)
      false
    end

    def validate_sample_sushi
      schema = load_schema
      report = self.attributes.except("compressed")
      report.transform_keys! { |key| key.tr('_', '-') }
      size = report["report-datasets"].length
      if (size/8) > 0  
        sample = (size/8) > 100 ? 100 : size
      else
        sample = 1
      end
      report["report-datasets"] = report["report-datasets"].sample(sample)
      JSON::Validator.fully_validate(schema, report.to_json, :errors_as_objects => true)
    end

    def is_valid_sushi? 
      schema = load_schema
      # report = self.attributes.except("compressed").deep_transform_keys { |key| key.tr('_', '-') }
      report = self.attributes.except("compressed")
      report.transform_keys! { |key| key.tr('_', '-') }
      JSON::Validator.validate(schema, report.to_json)
    end

    def load_schema
      if self.is_a?(ReportSubset)
        release = self.report.release
      else
        report = self.attributes.except("compressed")
        #report.transform_keys! { |key| key.tr('_', '-') }
        release = report.dig("release")
      end
      
      file = case release
             when 'rd1' then "lib/sushi_schema/sushi_usage_schema.json"
             when 'drl' then "lib/sushi_schema/sushi_resolution_schema.json"
             end

      begin
        File.read(file)
      rescue
        Rails.logger.error 'must redo the JSON schema file'
        {} # return an empty hash
      end
    end
  end
end
