require 'digest'
require 'base64'

class ReportSubset < ApplicationRecord
  belongs_to :report, primary_key: "uid", foreign_key: "report_id"

  validates_presence_of :report_id
  after_validation :make_checksum
  before_create :set_id
  # include validation methods for sushi
  include Metadatable
  after_commit :validate_report_job, on: :create


  def validate_report_job
    ValidationJob.perform_later(id)
  end

  def gzip
    ::Base64.strict_encode64(compressed)
  end

  def make_checksum
    write_attribute(:checksum, Digest::SHA256.hexdigest(compressed))
  end

  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end

 

end
