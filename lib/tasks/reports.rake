namespace :reports do
  desc "Index all reports"
  task index: :environment do
    logger = Logger.new(STDOUT)
    release = ENV['REPORT_TYPE'] ||= "rd1"
    logger.info "indexing reports of type #{release}" if release

    Report.where(release: release).find_each do |report|
      if report.normal_report?
        body = { report_id: report.report_url }
        report.send_message(body)
        logger.info "[UsageReportsRake] Queued indexing for #{report.uid} Data Usage Reports."
      elsif report.compressed_report?
        report.report_subsets.each do |subset|
          if subset.aasm == "valid"
            body = { report_id: subset.report_subset_url }
            subset.send_message(body)
            logger.info "[UsageReportsRake] Queued indexing #{subset.id} for #{report.uid} Data Usage Reports."
          else
            logger.warn "[UsageReportsRake] Report #{report.uid} has invalid subset #{subset.id}."
          end
        end
      end
    end
  end

  desc "Index single report"
  task index_report: :environment do
    logger = Logger.new(STDOUT)

    if ENV["REPORT_UUID"].nil?
      logger.error "#{ENV['REPORT_UUID']} is required (REPORT_UUID=UUID)."
      exit
    end

    report = Report.where(uid: ENV["REPORT_UUID"]).first
    if report.nil?
      logger.error "Report #{ENV['REPORT_UUID']} not found."
      exit
    end

    if report.normal_report?
      body = { report_id: report.report_url }
      report.send_message(body)
      logger.info "[UsageReportsRake] Queued indexing for #{report.uid} Data Usage Reports."
    elsif report.compressed_report?
      report.report_subsets.each do |subset|
        if subset.aasm == "valid"
          body = { report_id: subset.report_subset_url }
          subset.send_message(body)
          logger.info "[UsageReportsRake] Queued indexing #{subset.id} for #{report.uid} Data Usage Reports."
        else
          logger.warn "[UsageReportsRake] Report #{report.uid} has invalid subset #{subset.id}."
        end
      end
    end
  end

  desc "Validate all reports"
  task validate: :environment do
    Report.all.find_each do |report|
      if report.compressed_report?
        report.report_subsets.each do |subset|
          subset.validate_report_job(validate_only: true)
        end
      end
    end
  end

  desc "Validate single report"
  task validate_report: :environment do
    logger = Logger.new(STDOUT)

    if ENV["REPORT_UUID"].nil?
      logger.error "#{ENV['REPORT_UUID']} is required."
      exit
    end

    report = Report.where(uid: ENV["REPORT_UUID"]).first
    if report.nil?
      logger.error "Report #{ENV['REPORT_UUID']} not found."
      exit
    end

    if report.compressed_report?
      report.report_subsets.each do |subset|
        subset.validate_report_job(validate_only: true)
      end
    end
  end

  desc "Convert JSON of all reports"
  task convert: :environment do
    Report.all.find_each do |report|
      if report.compressed_report?
        if report.compressed_report?
          report.report_subsets.each(&:convert_report_job)
        end
      end
    end
  end

  desc "Convert JSON single report"
  task convert_report: :environment do
    logger = Logger.new(STDOUT)

    if ENV["REPORT_UUID"].nil?
      logger.error "#{ENV['REPORT_UUID']} is required."
      exit
    end

    report = Report.where(uid: ENV["REPORT_UUID"]).first
    if report.nil?
      logger.error "Report #{ENV['REPORT_UUID']} not found."
      exit
    end

    if report.compressed_report?
      if report.compressed_report?
        report.report_subsets.each(&:convert_report_job)
      end
    end
  end

  desc "Export single report to file."
  task export_report: :environment do
    logger = Logger.new(STDOUT)

    if ENV["REPORT_UUID"].nil?
      logger.error "'REPORT_UUID' is required on command line (REPORT_UUID=UUID)."
      exit
    end

    report = Report.where(uid: ENV["REPORT_UUID"]).first
    
    if report.nil?
      logger.error "Report #{ENV['REPORT_UUID']} not found."
      exit
    end

    if report.attachment.present?
      logger.info "[UsageReportsRake] REPORT ALREADY EXPORTED: #{report.uid}"
      exit
    end

    if report.normal_report?
      logger.info "[UsageReportsRake] EXPORTING NORMAL REPORT: #{report.uid}"
    elsif report.compressed_report?
      logger.info "[UsageReportsRake] EXPORTING COMPRESSED REPORT: #{report.uid}"
    end

    response = Faraday.get "#{report.report_url}"
    if response.status == 200
      output = response.body
      report.save_as_attachment(output)
    else
      logger.error "[UsageReportsRake] error - response status #{response.status}"
      exit
    end
    logger.info output
  end
end
