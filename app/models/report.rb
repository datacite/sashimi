require 'base32/url'
require 'digest'
require 'yajl'


class Report < ApplicationRecord
  self.primary_key = :uid

  has_many :report_subsets, autosave: true, dependent: :destroy

  # has_one_attached :report
  COMPRESSED_HASH_MESSAGE = {"code"=>69, "severity"=>"warning", "message"=>"report is compressed using gzip", "help-url"=>"https://github.com/datacite/sashimi", "data"=>"usage data needs to be uncompressed"}

  # include validation methods for sushi
  include Metadatable

  # include validation methods for sushi
  include Queueable 

  # attr_accessor :month, :year, :compressed
  validates_presence_of :report_id, :created_by, :client_id, :provider_id, :created, :reporting_period 
  validates_presence_of :report_datasets, if: :normal_report?
  #, :report_datasets
  validates :uid, uniqueness: true
  validates :validate_sushi, sushi: {presence: true}, if: :normal_report?
  attr_readonly :created_by, :month, :year, :client_id, :report_id, :uid

  # serialize :exceptions, Array
  before_validation :set_uid, on: :create
  after_save :to_compress 
  after_validation :clean_datasets
  # before_create :set_id
  after_commit :push_report, if: :normal_report?
  after_commit :validate_report_job, unless: :normal_report?


  def validate_report_job
    ValidationJob.perform_later(self)
  end

  def push_report
    logger.warn "calling queue for " + uid
    queue_report if ENV["AWS_REGION"].present?
  end

  def compress
    json_report = {
      "report-header": 
      {
        "report-name": self.report_name,
          "report-id": self.report_id,
          "release": self.release,
          "created": self.created,
          "created-by": self.created_by,
          "reporting-period": self.reporting_period,
          "report-filters": self.report_filters,
          "report-attributes": self.report_attributes,
          "exceptions": self.exceptions
        },
        "report-datasets": self.report_datasets
    }

    ActiveSupport::Gzip.compress(json_report.to_json)
  end
  
  # def encode_compressed
  #   return nil if self.compressed.nil?
  #   Base64.strict_encode64(self.compressed)
  # end

  # def checksum
  #   return nil if self.compressed.nil?
  #    Digest::SHA256.hexdigest(self.compressed)
  # end

  def compressed_report?
    return nil if self.exceptions.empty? 
    return nil if self.compressed.nil?
    # self.exceptions.include?(COMPRESSED_HASH_MESSAGE)
    code = self.exceptions.first.fetch("code","")
    if code == 69
      true
    else
      nil
    end
  end

  private

  # random number that fits into MySQL bigint field (8 bytes)
  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end

  def to_compress
    if  self.compressed.nil?
      puts "heheher right"
      ReportSubset.create(compressed: compress, report_id: self.uid)
    elsif self.report_subsets.empty?
    # else
      puts "hfhfhfhfhf"
      ReportSubset.create(compressed: self.compressed, report_id: self.uid)
      # ReportSubset.create(compressed: self.compressed, report_id: self.report_id)
    end
  end

  def clean_datasets
    write_attribute(:report_datasets, []) if compressed_report?
  end

  # def compressed_message
  #   [{
  #     empty: "too large",
  #     checksum: checksum,
  #   }]
  # end

  def report_datasets
    self.report_datasets unless compressed_report?
    # self.report_subsets
    []
  end

  def normal_report?
    return nil if compressed_report?
    return nil if self.report_datasets.nil?
    true
  end

  # def compressed_report?
  #   return nil if self.exceptions.empty? 
  #   return nil if self.compressed.nil?
  #   # self.exceptions.include?(COMPRESSED_HASH_MESSAGE)
  #   code = self.exceptions.first.fetch("code","")
  #   if code == 69
  #     true
  #   else
  #     nil
  #   end
  # end



  def set_uid
    return ActionController::ParameterMissing if self.reporting_period.nil?
    self.uid = SecureRandom.uuid if uid.blank?
    # self.report_id = self.uid 
    month = Date.strptime(self.reporting_period["begin_date"],"%Y-%m-%d").month.to_s 
    year = Date.strptime(self.reporting_period["begin_date"],"%Y-%m-%d").year.to_s 
    write_attribute(:month,  month ) 
    write_attribute(:year,  year) 
  end
end
