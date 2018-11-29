class ValidationJob < ActiveJob::Base
  queue_as :sashimi


  def perform(item, options={})
    logger = Logger.new(STDOUT)

    full_report = ActiveSupport::Gzip.decompress(item.compressed)
    parsed =JSON.parse((full_report))
    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    report = Report.where(uid: item.report.uid).first
    
    valid =  item.validate_this_sushi(header)
    if valid.empty?
      message = "A subset of Usage Report #{item.report.uid} successfully validated and ready to Push"
      # item.push_report
      report.push_report
    else
      message = "A subset of Usage Report #{item.report.uid} fail validation. Needs to be updated, there are #{valid.size} errors. For example: #{valid.first[:message]}"
      report.exceptions = valid
    end
    logger.info message
    return report.exceptions unless valid.empty?
    true
  end
end
