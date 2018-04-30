class ReportJob < ActiveJob::Base
  queue_as :usage

  def perform(report, options={})
    Rails.logger.debug "Queue Report #{report.uid}"
    report.queue_report(options)
  end
end