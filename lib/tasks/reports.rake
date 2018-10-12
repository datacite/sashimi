namespace :reports do

  desc 'Index all reports'
  task :index => :environment do
    logger = Logger.new(STDOUT)
    reports = Report.all
    reports.each do |report|
      logger.info report.uid
      report.queue_report
      logger.info "Queued indexing for #{report.uid} Data Usage Reports."
    end
  end
end
