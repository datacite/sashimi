require "digest"
require "base64"

### Subset are never updated. there will be always deleted and recreated
class ReportSubset < ApplicationRecord
  # include validation methods for sushi
  include Queueable

  # include validation methods for sushi
  include Metadatable

  belongs_to :report, primary_key: "uid", foreign_key: "report_id"

  validates_presence_of :report_id
  after_validation :make_checksum
  before_create :set_id

  after_commit :validate_report_job, on: :create

  def validate_report_job(options = {})
    ValidationJob.perform_later(id, options)
  end

  def convert_report_job
    ConvertJob.perform_later(id)
  end

  def push_report
    return false if aasm != "valid"

    Rails.logger.info "[UsageReports] calling queue for #{id}"
    body = { report_id: report_subset_url }

    send_message(body) if ENV["AWS_REGION"].present?
  end

  def gzip
    ::Base64.strict_encode64(compressed)
  end

  def validate_compressed(options = {})
    full_report = nil
    header = nil
    parsed = nil
    is_valid = nil

    bm = Benchmark.ms do
      # subset = ReportSubset.where(id: id).first
      full_report = ActiveSupport::Gzip.decompress(compressed)
    end
    Rails.logger.warn message: "[ValidationJob] Decompress", duration: bm

    bm = Benchmark.ms do
      parsed = JSON.parse(full_report)
    end
    Rails.logger.warn message: "[ValidationJob] Parse", duration: bm

    header = parsed.dig("report-header")
    header["report-datasets"] = parsed.dig("report-datasets")

    bm = Benchmark.ms do
      # validate subset of usage report, raise error with bug tracker otherwise
      is_valid = validate_this_sushi_with_error(header)
    end
    Rails.logger.warn message: "[ValidationJob] Validation", duration: bm
    if is_valid
      message = "[ValidationJob] Subset #{id} of Usage Report #{report.uid} successfully validated."
      update_column(:aasm, "valid")
      report.update_state
      push_report unless options[:validate_only]
      Rails.logger.info message
      true
    else
      # store error details in database
      validation_errors = validate_this_sushi(header)

      message = "[ValidationJobError] Subset #{id} of Usage Report #{report.uid} failed validation. There are #{validation_errors.size} errors, starting with \"#{validation_errors.first[:message]}\"."
      update_columns(aasm: "not_valid", exceptions: validation_errors)
      report.update_state
      Rails.logger.error message
      false
    end
  end

  def report_header
    report = Report.where(uid: report_id).first

    fail ActiveRecord::RecordNotFound if report.blank?

    {
      "report-name": report.report_name,
      "report-id": report.report_id,
      "release": report.release,
      "created": report.created,
      "created-by": report.created_by,
      "reporting-period": report.reporting_period,
      "report-filters": report.report_filters,
      "report-attributes": report.report_attributes,
      "exceptions": report.exceptions,
    }
  end

  def make_checksum
    write_attribute(:checksum, Digest::SHA256.hexdigest(compressed))
  end

  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end
end
