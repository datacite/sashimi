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
  # Tasks for migration from report db storage to file system storage.
  #
  #
  # MIGRATION INCLUDES:
  #   1. Generate report files in first pass.
  #   2. Clean fields in database that contain large almounts of data.
  #      - report.compressed
  #      - report.datasets
  #      - report_subsets.compressed
  #
  # The migration tasks are separate because we want to make sure the reports are fully
  # generated before we clean the database data.

  namespace :export do

    # SYNTAX: bundle exec rake reports:export[uuid]
    desc "Export report to file."
    task :report, [:uuid] => [:environment] do |task, args|
      logger = Logger.new(STDOUT)

      uuid = args.uuid

      report = Report.where(uid: uuid).first

      if report.nil?
        logger.info "[UsageReportsRake] Report not found for export: #{uuid}."
      elsif (report.attachment.present?)
        logger.info "[UsageReportsRake] Report already exported: #{uuid}."
      else
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

    task :compressed, [:uuid] => [:environment] do |task, args|
      logger = Logger.new(STDOUT)

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      n_processed = 0
      n_errors = 0
      n_already_done = 0
      n_retrieved = Report.where(release: ["rd1", "rd2"]).merge(Report.where("exceptions LIKE '%?%'", 69)).count
      Report.where(release: ["rd1", "rd2"]).merge(Report.where("exceptions LIKE ?", "%: 69,%")).find_each do |report|
        # logger.info "UID: #{report.uid}, created_at: #{report.created_at}"

        if (report.attachment.present? && report.attachment.exists?)
          n_already_done += 1
          logger.info "[UsageReportsRake] Report already exported: #{report.uid}.\n"
        else
          # Get rendered report
          @rails_session ||= ActionDispatch::Integration::Session.new(Rails.application)
          @rails_session.get("/reports/#{report.uid}")

          content = @rails_session.response.body

          # Save rendered report and clean up db fields.
          report.save_as_attachment(content)

          if report.attachment.present? && report.attachment.exists?
            # MAKING THIS A SEPARATE TASK TO PRESERVE DATA UNTIL WE ARE SURE CORRECT REPORTS HAVE BEEN GENERATED.
            # Clean data from DB only if export was successful. - Making this a separate task.
            # report.clean_data
            # logger.info "Report export SUCCESSFUL: #{uuid}, #{report_type(report)}."
            n_processed += 1
            logger.info "[UsageReportsRake] Report export SUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          else
            n_errors += 1
            # logger.error "Report export UNSUCCESSFUL: #{uuid}, #{report_type(report)}."
            logger.info "[UsageReportsRake] Report export UNSUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          end
          logger.info "PROCESSED SO FAR: #{n_processed + n_already_done}, LEFT TO GO: #{n_retrieved - (n_processed + n_already_done)}, ERRORS: #{n_errors}\n"
          sleep(5)
        end
      end

      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      logger.info "**EXPORT FINISHED - ELAPSED TIME: #{(ending - starting)/60} minutes**"
      logger.info "TOTAL COMPRESSED REPORTS RETRIEVED FROM DB: #{n_retrieved}"
      logger.info "TOTAL RESOLUTION REPORTS ALREADY DONE: #{n_already_done}"
      logger.info "TOTAL COMPRESSED REPORTS PROCESSED SUCCESSFULLY: #{n_processed}"
      logger.info "TOTAL COMPRESSED REPORTS PROCESSED WITH ERRORS: #{n_errors}"
    end

    task :normal, [:uuid] => [:environment] do |task, args|
      logger = Logger.new(STDOUT)

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      n_processed = 0
      n_errors = 0
      n_already_done = 0
      n_retrieved = Report.where(release: ["rd1", "rd2"]).merge(Report.where.not("exceptions LIKE ?", "%: 69,%")).count
      Report.where(release: ["rd1", "rd2"]).merge(Report.where.not("exceptions LIKE ?", "%: 69,%" )).find_each do | report |
        # logger.info "UID: #{report.uid}, created_at: #{report.created_at}"

        if (report.attachment.present? && report.attachment.exists?)
          n_already_done += 1
          logger.info "[UsageReportsRake] Report already exported: #{report.uid}.\n"
        else
          # Get rendered report
          @rails_session ||= ActionDispatch::Integration::Session.new(Rails.application)
          @rails_session.get("/reports/#{report.uid}")

          content = @rails_session.response.body

          # Save rendered report and clean up db fields.
          report.save_as_attachment(content)

          if report.attachment.present? && report.attachment.exists?
            # MAKING THIS A SEPARATE TASK TO PRESERVE DATA UNTIL WE ARE SURE CORRECT REPORTS HAVE BEEN GENERATED.
            # Clean data from DB only if export was successful. - Making this a separate task.
            # report.clean_data
            # logger.info "Report export SUCCESSFUL: #{uuid}, #{report_type(report)}."
            n_processed += 1
            logger.info "[UsageReportsRake] Report export SUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          else
            n_errors += 1
            # logger.error "Report export UNSUCCESSFUL: #{uuid}, #{report_type(report)}."
            logger.info "[UsageReportsRake] Report export UNSUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          end
          logger.info "PROCESSED SO FAR: #{n_processed + n_already_done}, LEFT TO GO: #{n_retrieved - (n_processed + n_already_done)}, ERRORS: #{n_errors}\n"
          sleep(5)
        end
      end

      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      logger.info "**EXPORT FINISHED - ELAPSED TIME: #{(ending - starting)/60} minutes**"
      logger.info "TOTAL NORMAL REPORTS RETRIEVED FROM DB: #{n_retrieved}"
      logger.info "TOTAL NORMAL REPORTS ALREADY DONE: #{n_already_done}"
      logger.info "TOTAL NORMAL REPORTS PROCESSED SUCCESSFULLY: #{n_processed}"
      logger.info "TOTAL NORMAL REPORTS PROCESSED WITH ERRORS: #{n_errors}"
    end

    task :resolution, [:uuid] => [:environment] do |task, args|
      logger = Logger.new(STDOUT)

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      n_processed = 0
      n_errors = 0
      n_already_done = 0
      n_retrieved = Report.where(release: ["drl"]).merge(Report.where("exceptions LIKE ?", "%: 69,%")).count
      Report.where(release: ["drl"]).merge(Report.where("exceptions LIKE ?", "%: 69,%" )).find_each do | report |
        # logger.info "UID: #{report.uid}, created_at: #{report.created_at}"

        if (report.attachment.present? && report.attachment.exists?)
          n_already_done += 1
          logger.info "[UsageReportsRake] Report already exported: #{report.uid}.\n"
        else
          # Get rendered report
          @rails_session ||= ActionDispatch::Integration::Session.new(Rails.application)
          @rails_session.get("/reports/#{report.uid}")

          content = @rails_session.response.body

          # Save rendered report and clean up db fields.
          report.save_as_attachment(content)

          if report.attachment.present? && report.attachment.exists?
            # MAKING THIS A SEPARATE TASK TO PRESERVE DATA UNTIL WE ARE SURE CORRECT REPORTS HAVE BEEN GENERATED.
            # Clean data from DB only if export was successful. - Making this a separate task.
            # report.clean_data
            # logger.info "Report export SUCCESSFUL: #{uuid}, #{report_type(report)}."
            n_processed += 1
            logger.info "[UsageReportsRake] Report export SUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          else
            n_errors += 1
            # logger.error "Report export UNSUCCESSFUL: #{uuid}, #{report_type(report)}."
            logger.info "[UsageReportsRake] Report export UNSUCCESSFUL: #{report.uid}. (#{report_type(report)})\n"
          end
          logger.info "PROCESSED SO FAR: #{n_processed + n_already_done}, LEFT TO GO: #{n_retrieved - (n_processed + n_already_done)}, ERRORS: #{n_errors}\n"

          sleep(5)
        end
      end

      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      logger.info "**EXPORT FINISHED - ELAPSED TIME: #{(ending - starting)/60} minutes**"
      logger.info "TOTAL RESOLUTION REPORTS RETRIEVED FROM DB: #{n_retrieved}"
      logger.info "TOTAL RESOLUTION REPORTS ALREADY DONE: #{n_already_done}"
      logger.info "TOTAL RESOLUTION REPORTS PROCESSED SUCCESSFULLY: #{n_processed}"
      logger.info "TOTAL RESOLUTION REPORTS PROCESSED WITH ERRORS: #{n_errors}"
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

  # SYNTAX: bundle exec rake reports:export[uuid]
  desc "Clean report data."
  task :clean, [:uuid] => [:environment] do |task, args|
    logger = Logger.new(STDOUT)

    if args.class == String
      uuid = args
    else
      uuid = args.uuid
    end

    # uuid = args[:uuid]
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

  # SYNTAX: bundle exec rake reports:clean_all
  desc "Clean report data from db, making sure that data is in the file system."
  task clean_all: :environment do
    logger = Logger.new(STDOUT)

    n_processed = 0
    n_errors = 0
    n_retrieved = Report.all.count

    Report.all.find_each do |report|
      if (!report.attachment.present? || !report.attachment.exists?)
        # Make sure attachment has been generated before we clean out report data.
        n_errors += 1
        logger.info "[UsageReportsRake] Report not yet eligible for cleaning: #{report.uid}."
        logger.info "[UsageReportsRake] Report cleaning UNSUCCESSFUL: #{report.uid}. (#{report_type(report)})"
      else
        n_processed += 1
        report.clean_data
        logger.info "[UsageReportsRake] Report cleaning SUCCESSFUL: #{report.uid}. (#{report_type(report)})"
      end
    end

    logger.info "Reports cleaned = #{n_processed}"
    logger.info "Reports with errors cleaning = #{n_errors}"
    logger.info "Total reports retrieved = #{n_retrieved}"
  end

  namespace :status do

    # SYNTAX: bundle exec rake reports:exported
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
          logger.info "[UsageReportsRake] Report has NOT BEEN EXPORTED: #{report.uid}."
        end
        # sleep(5)
      end

      logger.info "Reports already exported = #{n_exported}"
      logger.info "Reports NOT yet exported = #{n_not_exported}"
      logger.info "Total reports = #{total}"
    end

    # SYNTAX: bundle exec rake reports:exported
    desc "Check totals of different types of reports."
    task totals: :environment do
      logger = Logger.new(STDOUT)
      n_exported = 0
      n_not_exported = 0
      n_compressed = 0
      n_resolution = 0
      n_normal = 0
      n_unknown = 0
      total = 0;

      Report.all.find_each do |report|
        total +=1
        if report.attachment.present?
          n_exported +=1
          # logger.info "[UsageReportsRake] Report has been **exported**: #{report.uid}."
        else
          n_not_exported +=1
          # logger.info "[UsageReportsRake] Report has NOT been exported: #{report.uid}."
        end

        if report.compressed_report?
          n_compressed += 1
        elsif report.normal_report?
          n_normal += 1
        elsif report.resolution_report?
          n_resolution += 1
        else
          n_unknown += 1
        end

        # sleep(5)
      end

      logger.info "Total compressed =  #{n_compressed}"
      logger.info "Total normal =  #{n_normal}"
      logger.info "Total resolution =  #{n_resolution}"
      logger.info "Total unknown =  #{n_unknown}"

      logger.info "Reports already exported = #{n_exported}"
      logger.info "Reports NOT yet exported = #{n_not_exported}"
      logger.info "Total reports = #{total}"
    end

  end

  # SYNTAX: bundle exec rake reports:attrs['uid']
  desc "Print report attributes."
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

    print_attrs(report)
  end

  # SYNTAX: bundle exec rake reports:attrs['uid']
  desc "Print report type."
  task :type, [:uid] => :environment do |task, args|
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

    logger.info "REPORT TYPE: #{report_type(report)}"
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

  def print_attrs (report = nil, csv_file = nil)
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
      "COMPRESSED REPORT"
    elsif report.resolution_report?
      "RESOLUTION REPORT"
    else
      "UNKNOWN REPORT TYPE"
    end
  end
end