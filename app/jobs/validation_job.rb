require 'benchmark'

class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    subset = nil
    full_report = nil
    subset = nil
    header = nil
    parsed = nil
    is_valid = nil

    bm = Benchmark.ms {
      subset = ReportSubset.where(id: id).first
      full_report = ActiveSupport::Gzip.decompress(subset.compressed)
    }
    Rails.logger.warn message: "[ValidationJob] Decompress", duration: bm

    bm = Benchmark.ms {
      parsed = JSON.parse(full_report)
    }
    Rails.logger.warn message: "[ValidationJob] Parse", duration: bm

    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    bm = Benchmark.ms {
      # validate subset of usage report, raise error with bug tracker otherwise
      is_valid = subset.validate_this_sushi_with_error(header)
    }
    Rails.logger.warn message: "[ValidationJob] Validation", duration: bm

    if is_valid
      message = "[ValidationJob] Subset #{id} of Usage Report #{subset.report.uid} successfully validated."
      subset.update_column(:aasm, "valid")
      subset.push_report unless options[:validate_only]
      Rails.logger.info message
      true
    else
      # store error details in database
      validation_errors =  subset.validate_this_sushi(header)

      message = "[ValidationJobError] Subset #{id} of Usage Report #{subset.report.uid} failed validation. There are #{validation_errors.size} errors, starting with \"#{validation_errors.first[:message]}\"."
      subset.update_columns(aasm: "not_valid", exceptions: validation_errors)
      Rails.logger.error message
      false
    end
  end
end
