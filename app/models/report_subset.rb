require 'digest'
require 'base64'

class ReportSubset < ApplicationRecord
  # include validation methods for sushi
  include Queueable

  # include validation methods for sushi
  include Metadatable

  attr_accessor :exceptions

  belongs_to :report, primary_key: "uid", foreign_key: "report_id"

  validates_presence_of :report_id
  after_validation :make_checksum
  before_create :set_id

  after_commit :validate_report_job, on: :create

  def validate_report_job
    ValidationJob.perform_later(id)
  end

  def push_report
    logger = Logger.new(STDOUT)
    logger.info "[UsageReports] calling queue for #{id}"
    
    queue_report_subset if ENV["AWS_REGION"].present?
  end

  def gzip
    ::Base64.strict_encode64(compressed)
  end

  def report_header
    report = Report.where(uid: report_id).first

    fail ActiveRecord::RecordNotFound unless report.present?
  
    {
      "report-name": report.report_name,
      "report-id": report.report_id,
      "release": report.release,
      "created": report.created,
      "created-by": report.created_by,
      "reporting-period": report.reporting_period,
      "report-filters": report.report_filters,
      "report-attributes": report.report_attributes,
      "exceptions": report.exceptions
     }
  end

  def make_checksum
    write_attribute(:checksum, Digest::SHA256.hexdigest(compressed))
  end

  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end
end
