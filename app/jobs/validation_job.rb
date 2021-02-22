require 'benchmark'

class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    subset = nil
    full_report = nil
    subset = nil
    header = nil
    parsed = nil
    is_valid = nil

    subset = ReportSubset.where(id: id).first
    if (id.nil? || subset.nil?)
      #message = "[ValidationJobError] Subset #{id} of Usage Report #{subset.report.uid} failed validation. There are #{validation_errors.size} errors, starting with \"#{validation_errors.first[:message]}\"."
      #Rails.logger.error message
      puts "SKV - THIS REPORT HAS NO SUBSET!!! BEGIN"
      puts id.inspect
      puts "SKV - THIS REPORT HAS NO SUBSET!!! END"
      true
    else
      bm = Benchmark.ms {
        subset = ReportSubset.where(id: id).first
        report = Report.where(uid: subset.report_id).first
        if report.attachment.present?
          content = report.load_attachment
          attachment = AttachmentParser.new(content)
          attachment_subset = attachment.search_subsets(checksum: subset.checksum)
          subset.compressed = attachment.subset_compressed(subset: attachment_subset)
        else
          # Rails.logger.info "VALIDATION - NO ATTACHMENT FOUND FOR THIS REPORT!"
        end
        Rails.logger.info report

        full_report = ActiveSupport::Gzip.decompress(subset.compressed)
      }
      Rails.logger.warn message: "[ValidationJob] Decompress", duration: bm

      bm = Benchmark.ms {
        parsed = JSON.parse(full_report)
      }
      Rails.logger.warn message: "[ValidationJob] Parse", duration: bm

      header = parsed.dig("report-header")
      header["report-datasets"] = parsed.dig("report-datasets")

      bm = Benchmark.ms {
        # validate subset of usage report, raise error with bug tracker otherwise
        is_valid = subset.validate_this_sushi_with_error(header)
      }
      Rails.logger.warn message: "[ValidationJob] Validation", duration: bm

      if is_valid
        message = "[ValidationJob] Subset #{id} of Usage Report #{subset.report.uid} successfully validated."
        subset.update_column(:aasm, "valid")
        subset.push_report unless options[:validate_only]
        Rails.logger.info message
        true
      else
        # store error details in database
        validation_errors =  subset.validate_this_sushi(header)

        message = "[ValidationJobError] Subset #{id} of Usage Report #{subset.report.uid} failed validation. There are #{validation_errors.size} errors, starting with \"#{validation_errors.first[:message]}\"."
        subset.update_columns(aasm: "not_valid", exceptions: validation_errors)
        Rails.logger.error message
        false
      end
    end
  end
end
