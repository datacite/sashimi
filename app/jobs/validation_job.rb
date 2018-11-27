class ValidationJob < ActiveJob::Base
  queue_as :sashimi


  def perform(item, options={})
    logger = Logger.new(STDOUT)

    full_report = ActiveSupport::Gzip.decompress(item.compressed)

    item.report_datasets = full_report
    valid =  item.validate_this_sushi(full_report)
    if valid
      message = "Usage Report #{item.uid} successfully validated and ready to Push"
      item.push_report
    else
      message = "Usage Report #{item.uid} fail validation. Needs to be updated"
      item.exceptions = valid
    end
    logger.info message
  end
end
