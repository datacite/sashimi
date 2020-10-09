module Metadatable
  extend ActiveSupport::Concern

  require "json-schema"
  require "fileutils"
  require "json"

  included do
    def validate_sushi
      schema = load_schema
      report = attributes.except("compressed", "aasm_state")
      report.transform_keys! { |key| key.tr("_", "-") }

      JSON::Validator.fully_validate(schema, report.to_json, errors_as_objects: true)
    end

    def validate_this_sushi(sushi)
      schema = load_schema
      JSON::Validator.fully_validate(schema, sushi.to_json, errors_as_objects: true)
    end

    def validate_this_sushi_with_error(sushi)
      schema = load_schema
      JSON::Validator.validate!(schema, sushi.to_json)
    rescue JSON::Schema::ValidationError => e
      Raven.capture_exception(e)
      false
    end

    def validate_sample_sushi
      schema = load_schema
      report = attributes.except("compressed", "aasm_state")
      report.transform_keys! { |key| key.tr("_", "-") }
      size = report["report-datasets"].length
      sample = if (size / 8) > 0
                 (size / 8) > 100 ? 100 : size
               else
                 1
               end
      report["report-datasets"] = report["report-datasets"].sample(sample)
      JSON::Validator.fully_validate(schema, report.to_json, errors_as_objects: true)
    end

    def is_valid_sushi?
      schema = load_schema
      report = attributes.except("compressed", "aasm_state")
      report.transform_keys! { |key| key.tr("_", "-") }
      JSON::Validator.validate(schema, report.to_json)
    end

    def load_schema
      if is_a?(ReportSubset)
        release = report.release
      else
        report = attributes.except("compressed", "aasm_state")
        release = report.dig("release")
      end

      file = case release
             when "rd1" then "lib/sushi_schema/sushi_usage_schema.json"
             when "drl" then "lib/sushi_schema/sushi_resolution_schema.json"
             end

      begin
        File.read(file)
      rescue StandardError
        Rails.logger.error "must redo the JSON schema file"
        {} # return an empty hash
      end
    end
  end
end
