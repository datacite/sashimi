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

  #
  # For migration from report db storage to file system storage.
  #

  # SYNTAX: bundle exec rake reports:export['805ad80f-ce16-4cf7-b8fc-93fa7c79655d']
  # MIGRATION INCLUDES:
  #   1. Generate report files in first pass. **(This script)**
  #   2. Clean fields in database that contain large almounts of data.
  #      - report.compressed
  #      - report.datasets
  #      - report_subsets.compressed
  desc "Export report to file."

  #task :export, [:uuid] => [:environment] do |task, args|
  task :export, [:uuid] => [:environment] do |task, args|
    logger = Logger.new(STDOUT)

    if args.class == String
      uuid = args
    else
      uuid = args.uuid
    end

    report = Report.where(uid: uuid).first

    if report.nil?
      logger.info "[UsageReportsRake] Report not found for export: #{uuid}."
    elsif (report.attachment.present?)
      logger.info "[UsageReportsRake] Report already exported: #{uuid}."
    else
      # Some conversion needed.
      # report.compressed = nil
      if (report.report_subsets.empty?)
        report_subset = report.to_compress
      else
        report_subset = report.report_subsets.first
      end
      # report.update_column('compressed', report_subset.compressed)

      # Get rendered report
      @rails_session ||= ActionDispatch::Integration::Session.new(Rails.application)
      @rails_session.get("/reports/#{uuid}")

      content = @rails_session.response.body

      # Save rendered report and clean up db fields.
      report.save_as_attachment(content)

      if report.attachment.present? && report.attachment.exists?
        # MAKING THIS A SEPARATE TASK TO PRESERVE DATA UNTIL WE ARE SURE CORRECT REPORTS HAVE BEEN GENERATED.
        # Clean data from DB only if export was successful. - Making this a separate task.
        # report.clean_data
        # logger.info "Report export SUCCESSFUL: #{uuid}, #{report_type(report)}."
        puts "UsageReportsRake] Report export SUCCESSFUL: #{uuid}. (#{report_type(report)})"
      else
        # logger.error "Report export UNSUCCESSFUL: #{uuid}, #{report_type(report)}."
        puts "UsageReportsRake] Report export UNSUCCESSFUL: #{uuid}. (#{report_type(report)})"
      end
    end
  end

  # SYNTAX: bundle exec rake reports:export_all
  desc "Export JSON of all reports"
  task export_all: :environment do
    Report.all.find_each do |report|
      Rake::Task['reports:export'].execute report.uid.to_s
      # sleep(5)
      if !confirm
        exit
      end
    end
  end

  # SYNTAX: bundle exec rake reports:export['805ad80f-ce16-4cf7-b8fc-93fa7c79655d']
  # MIGRATION INCLUDES:
  #   1. Generate report files in first pass.
  #   2. Clean fields in database that contain large almounts of data. **(This script)**
  #      - report.compressed
  #      - report.datasets
  #      - report_subsets.compressed
  desc "Clean report data."
  task :clean, [:uuid] => [:environment] do |task, args|
    logger = Logger.new(STDOUT)

    uuid = args[:uuid]
    report = Report.where(uid: uuid).first

    if report.nil?
      logger.info "[UsageReportsRake] Report not found for cleaning: #{uuid}."
    elsif (!report.attachment.present? || !report.attachment.exists?)
      # Make sure attachment has been generated before we clean out report data.
      logger.info "[UsageReportsRake] Report not yet eligible for cleaning: #{uuid}."
      logger.info "[UsageReportsRake] Report cleaning UNSUCCESSFUL: #{uuid}. (#{report_type(report)})"
    else
      report.clean_data
      logger.info "[UsageReportsRake] Report cleaning SUCCESSFUL: #{uuid}. (#{report_type(report)})"
    end
  end

  # SYNTAX: bundle exec rake reports:export_all
  desc "Clean JSON of all reports"
  task clean_all: :environment do
    Report.all.find_each do |report|
      Rake::Task['reports:clean'].execute report.uid
      sleep(5)
    end
  end

  # SYNTAX: bundle exec rake reports:export_all
  desc "Check whether reports have been exported."
  task exported: :environment do
    logger = Logger.new(STDOUT)
    n_exported = 0
    n_not_exported = 0
    total = 0

    Report.all.find_each do |report|
      total +=1
      if report.attachment.present?
        n_exported +=1
        logger.info "[UsageReportsRake] Report has been **exported**: #{report.uid}."
      else
        n_not_exported +=1
        logger.info "[UsageReportsRake] Report has NOT been exported: #{report.uid}."
      end
      # sleep(5)
    end

    logger.info "Reports exported = #{n_exported}"
    logger.info "Reports NOT exported = #{n_not_exported}"
    logger.info "Total reports = #{total}"
  end

  # SYNTAX: bundle exec rake reports:attrs['uid']
  desc "Print report attributes - including type."
  task :attrs, [:uid] => :environment do |task, args|
    logger = Logger.new(STDOUT)

    if args.uid.nil?
      logger.error "'REPORT_UID' is a required argument."
      exit
    end

    report = Report.where(uid: args.uid).first

    if report.nil?
      logger.error "Report #{args.uid} not found."
      exit
    end

    print_type(report)
  end

    # SYNTAX: bundle exec rake reports:paperclip
    desc "Print paperclip config - where are my report files?"
    task paperclip: :environment do
      puts "PAPERCLIP REPORT STORAGE PARAMETERS:"
      if Rails.application.config.paperclip_defaults.key?("s3_credentials")
        puts Rails.application.config.paperclip_defaults.except(:s3_credentials).to_yaml
      else
        puts Rails.application.config.paperclip_defaults.to_yaml
      end
    end

  # Find and list reports of given type. Ask every 5 reports if you want to continue.
  # SYNTAX: bundle exec rake reports:find['type',N]
  # WHERE: 'type' = 'normal' | 'compressed' | 'resolution'. (Default: 'normal'.)
  #        N = number of reports listed asked to confirm continuation. (Default: 10.)
  desc "find reports by type"
  task :find, [:type, :n_per] => :environment do |task, args|
    report_types =  ['normal', 'compressed', 'resolution']
    n = (args.n_per.strip.downcase || 10)
    type = (args.type.strip.downcase || 'normal')

    if (!report_types.include?(type))
      puts "INVALID ARG: 'type' must be one of #{report_types.join("', '")}"
      exit
    elsif !(n !~ /\D/)
      puts "INVALID ARG: N must be a postive integer"
      exit
    end

    puts "***LISTING: #{type} reports, #{n} per page"

    x = 0
    Report.all.find_each do |report|
      if (x >= n.to_i)
        if confirm
          x = 0
        else
          puts "EXITING..."
          exit
        end
      end
      if report.normal_report?
        puts report.uid
        x = x + 1
      elsif report.compressed_report?
        puts report.uid
        x = x + 1
      elsif report.resolution_report?
        puts report.uid
        x = x + 1
      else
        puts "SKIPPING... #{report.uid}"
      end
    end
  end

  # SYNTAX: bundle exec rake reports:paperclip
  desc "Print paperclip config - where are my report files?"
  task paperclip: :environment do
    puts "PAPERCLIP REPORT STORAGE PARAMETERS:"
    if Rails.application.config.paperclip_defaults.key?("s3_credentials")
      puts Rails.application.config.paperclip_defaults.except(:s3_credentials).to_yaml
    else
      puts Rails.application.config.paperclip_defaults.to_yaml
    end
  end

  def confirm
    $stdout.sync = true
    ask = true
    ret = false
    confirm_tokens =  ['y', 'Y', 'n', 'N', 'q', 'Q']

    while ask do
      STDOUT.puts "***CONTINUE? Enter '#{confirm_tokens.join("|")}|<NL>' to confirm:"
      input = STDIN.gets.chomp.strip.downcase
      if (input == 'y') || input.empty?
        # puts 'continuing...'
        ret = true
        ask = false
      elsif (input == 'n') || (input == 'q')
        ret = false
        ask = false
      else
        puts "INVALID ANSWER. Must answer one of '#{confirm_tokens.join("|")}|<NL>'"
      end
    end
    ret
  end

  def print_type (report = nil, csv_file = nil)
    if report.nil?
      return
    end
    separator = "\t"

    checksum = nil
    found_in_subset = false
    if report.compressed.present?
      checksum = Digest::SHA256.hexdigest(report.compressed)
      if (ReportSubset.where(checksum: checksum).count > 0)
        found_in_subset = true
      end
    end

    if csv_file.nil?
      puts "#{report_type(report)}: #{report.uid}, " +
        "TITLE: #{report.report_name}, " +
        "ATTACHMENT: #{ ( report.attachment.present? ? report.attachment_file_name : "NONE" ) }, " +
        "SUBSETS: #{report.report_subsets.count}, " +
        "COMPRESSED: #{report.compressed.present?} " +
        "#{ ( report.compressed.present? ?  " (CHECKSUM: #{checksum}, IN SUBSETS: #{found_in_subset})" : "") }"
    else
      csv_file.puts "#{report_type(report)}: #{report.uid}" + separator +
        "#{report.report_name}" + separator +
        "#{ ( report.attachment.present? ? report.attachment_file_name : "NONE" ) } " + separator +
        "#{report.report_subsets.count}, " + separator +
        "#{report.compressed.present?} " + separator +
        "#{checksum}" + separator + separator +
        "#{found_in_subset})"
    end
  end

  def report_type (report = nil)
    if report.nil?
      return ""
    end

    if report.normal_report?
      "NORMAL REPORT"
    elsif report.compressed_report?
      "COMPReSSED REPORT"
    elsif report.resolution_report?
      "RESOLUTION REPORT"
    else
      "UNKNOWN REPORT TYPE"
    end
  end
end