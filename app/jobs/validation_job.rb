class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    logger = Logger.new(STDOUT)

    subset = ReportSubset.where(id: id).first
    full_report = ActiveSupport::Gzip.decompress(subset.compressed)
    parsed = JSON.parse((full_report))
    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    # report = Report.where(uid: subset.report.uid).first
    
    validation_errors =  subset.validate_this_sushi(header)

    if validation_errors.empty?
      message = "[ValidationJob] Subset #{id} of Usage Report #{subset.report.uid} successfully validated."
      # item.push_report
      subset.push_report
      subset.update_column(:aasm, "valid")
      logger.info message
      true
    else
      message = "[ValidationJobError] Subset #{id} of Usage Report #{subset.report.uid} failed validation. There are #{validation_errors.size} errors, starting with \"#{validation_errors.first[:message]}\"."
      subset.update_column(:aasm, "not_valid")
      subset.report.update_column(:exceptions, validation_errors)
      logger.error message
      false
    end
  end
end
