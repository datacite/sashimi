module Metadatable
  extend ActiveSupport::Concern

  require 'json-schema'
  require 'fileutils'
  require 'json' 

  included do

    def validate_sushi 
      schema = load_schema
      report = self.attributes.deep_transform_keys { |key| key.tr('_', '-') }
      JSON::Validator.fully_validate(schema, report.to_json, :errors_as_objects => true)
    end

    def is_valid_sushi? 
      schema = load_schema
      report = self.attributes.deep_transform_keys { |key| key.tr('_', '-') }
      JSON::Validator.validate(schema, report.to_json)
    end
  
    USAGE_SCHEMA_FILE = "lib/sushi_schema/sushi_usage_schema.json"
    RESOLUTION_SCHEMA_FILE = "lib/sushi_schema/sushi_resolution_schema.json"

    def load_schema
      report = self.attributes.deep_transform_keys { |key| key.tr('_', '-') }
      file = report.dig("report-name") == "resolution report" && report.dig("created-by") == "datacite" ? RESOLUTION_SCHEMA_FILE : USAGE_SCHEMA_FILE   
      begin
        File.read(file)
      rescue
        puts 'must redo the settings file'
        {} # return an empty Hash object
      end
    end
  end
end
