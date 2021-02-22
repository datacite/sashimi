require 'optparse'
require 'optparse'

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

  # SYNTAX: bundle exec rake reports:export['805ad80f-ce16-4cf7-b8fc-93fa7c79655d']
  desc "Export report(s) to file."
  task :export, [:uuid] => [:environment] do |task, args|
    logger = Logger.new(STDOUT)

    puts args
    uuid = args

    report = Report.where(uid: uuid).first

    if report.nil?
      logger.info "[UsageReportsRake] Report not found for export: #{uuid}."
    elsif (report.attachment.present?)
      logger.info "[UsageReportsRake] Report already exported: #{uuid}."  
    else
      # Some conversion needed.
      report.compressed = nil
      if (report.report_subsets.empty?)
        report_subset = report.to_compress
      else
        report_subset = report.report_subsets.first
      end
      report.update_column('compressed', report_subset.compressed)

      # Get rendered report
      @rails_session ||= ActionDispatch::Integration::Session.new(Rails.application)
      @rails_session.get("/reports/#{uuid}")

      content = @rails_session.response.body

      # Save rendered report and clean up db fields.
      report.save_as_attachment(content)

      if report.attachment.exists?
        report.clean_data
        logger.info "[UsageReportsRake] Report exported successfully: #{uuid}."
      else
        logger.error "[UsageReportsRake] Report export UNSUCCESSFUL: #{uuid}."
      end
    end
  end

  desc "Export JSON of all reports"
  task export_all: :environment do
    Report.all.find_each do |report|
      Rake::Task['reports:export'].execute report.uid
    end
  end

  desc "test arguments"
  task :argtest, [:arg1Name] do |t, args|

    # t = the task name (includes the namespace)
    # args = all of the arguments passed to the task
    # args[:arg1Name] = the argument at the key :arg1Name
    puts "in task 'argtest':  t: #{t} args: #{args}  args[:arg1Name]: #{args[:arg1Name]}"
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

  desc "What kind of report is this?"
  task report_type: :environment do
    logger = Logger.new(STDOUT)

    if ENV["REPORT_UUID"].nil?
      logger.error "'REPORT_UUID' is required on command line (REPORT_UUID=UUID)."
      exit
    end

    report = Report.where(uid: ENV["REPORT_UUID"]).first

    if report.nil?
      logger.error "Report #{ENV["REPORT_UUID"]} not found."
      exit
    end

    logger.info "[UsageReportsRake] REPORT RELEASE IS: #{report.release}"
    if report.normal_report?
      logger.info "[UsageReportsRake] EXPORTING NORMAL REPORT: #{report.uid}"
    elsif report.compressed_report?
      logger.info "[UsageReportsRake] EXPORTING COMPRESSED REPORT: #{report.uid}"
    elsif report.resolution_report?
      logger.info "[UsageReportsRake] EXPORTING RESOLUTION REPORT: #{report.uid}"
    else
      logger.error "[UsageReportsRake] UNKNOWN REPORT TYPE: #{report.uid}"
    end
  end
end
