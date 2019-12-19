class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    subset = ReportSubset.where(id: id).first
    full_report = ActiveSupport::Gzip.decompress(subset.compressed)
    parsed = JSON.parse((full_report))
    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    # validate subset of usage report, raise error with bug tracker otherwise
    is_valid = subset.validate_this_sushi_with_error(header)

    if is_valid
      message = "[ValidationJob] Subset #{id} of Usage Report #{subset.report.uid} successfully validated."
      subset.push_report
      subset.update_column(:aasm, "valid")
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
