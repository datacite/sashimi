namespace :reports do
  desc 'Index all reports'
  task :index => :environment do
    logger = Logger.new(STDOUT)
    
    Report.all.find_each do |report|
      if report.normal_report?
        report.queue_report
        logger.info "[UsageReports] Queued indexing for #{report.uid} Data Usage Reports."
      elsif report.compressed_report?
        report.report_subsets.each do |subset|
          if subset.aasm == "valid"
            subset.queue_report_subset 
            logger.info "[UsageReports] Queued indexing #{subset.id} for #{report.uid} Data Usage Reports."
          else
            logger.warn "[UsageReports] Report #{report.uid} has invalid subsets #{subset.id}."
          end
        end
      end
    end
  end

  desc 'Index single report'
  task :index_report => :environment do
    logger = Logger.new(STDOUT)

    if ENV['REPORT_UUID'].nil?
      logger.error "#{ENV['REPORT_UUID']} is required."
      exit
    end

    report = Report.where(uid: ENV['REPORT_UUID']).first

    if report.normal_report?
      report.queue_report
      logger.info "[UsageReports] Queued indexing for #{report.uid} Data Usage Reports."
    elsif report.compressed_report?
      report.report_subsets.each do |subset|
        if subset.aasm == "valid"
          subset.queue_report_subset 
          logger.info "[UsageReports] Queued indexing #{subset.id} for #{report.uid} Data Usage Reports."
        else
          logger.warn "[UsageReports] Report #{report.uid} has invalid subsets #{subset.id}."
        end
      end
    end
  end
end
