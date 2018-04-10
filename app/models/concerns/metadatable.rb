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
  
    SUSHI_SCHEMA_FILE = "/home/app/webapp/spec/fixtures/files/sushi_schema.json"

    def load_schema
      content = begin
        File.read(SUSHI_SCHEMA_FILE)
      rescue
        puts 'must redo the settings file'
        {} # return an empty Hash object
      end
    end
  end
end
