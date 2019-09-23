class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    logger = Logger.new(STDOUT)

    subset = ReportSubset.where(id: id).first
    full_report = ActiveSupport::Gzip.decompress(subset.compressed)
    parsed =JSON.parse((full_report))
    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    # report = Report.where(uid: subset.report.uid).first
    
    valid =  subset.validate_this_sushi(header)
    if valid.empty?
      message = "[ValidationJob] A subset of Usage Report #{subset.report.uid} successfully validated and ready to Push"
      # item.push_report
      subset.push_report
      subset.update_column(:aasm, "valid")
      logger.info message
    else
      message = "[ValidationJob] A subset of Usage Report #{subset.report.uid} failed validation. Needs to be updated, there are #{valid.size} errors. For example: #{valid.first[:message]}"
      subset.exceptions = valid
      subset.update_column(:aasm, "not_valid")
      logger.error message
    end

    return subset.exceptions unless valid.empty?

    true
  end
end
