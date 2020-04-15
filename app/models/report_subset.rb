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
  validates_format_of :created_by, with: /[-\._;()\/:a-zA-Z0-9\*~\$\=]+\z/, on: :create
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
