require "base64"
require "digest"

class Report < ApplicationRecord
  self.primary_key = :uid

  has_many :report_subsets, autosave: true, dependent: :destroy

  has_attached_file :attachment
  validates_attachment_file_name :attachment, matches: [/json\z/]

  # has_one_attached :report
  COMPRESSED_HASH_MESSAGE = { "code" => 69, "severity" => "warning", "message" => "report is compressed using gzip", "help-url" => "https://github.com/datacite/sashimi", "data" => "usage data needs to be uncompressed" }.freeze

  # include validation methods for sushi
  include Metadatable

  # include validation methods for sushi
  include Queueable

  # attr_accessor :month, :year, :compressed
  validates_presence_of :report_id, :created_by, :user_id, :created, :reporting_period
  validates_presence_of :report_datasets, if: :normal_report?
  validates_format_of :created_by, with: /[-\._;()\/:a-zA-Z0-9\*~\$\=]+\z/, on: :create

  # , :report_datasets
  validates :uid, uniqueness: true
  validates :validate_sushi, sushi: { presence: true }, if: :normal_report?
  attr_readonly :created_by, :month, :year, :user_id, :report_id, :uid

  # serialize :exceptions, Array
  before_validation :set_uid, on: :create
  after_save :to_compress
  after_validation :clean_datasets
  # before_create :set_id
  after_commit :push_report, if: :normal_report?

  def set_data
    update_column("compressed", nil)
    report_subsets.each do | report_subset |
      report_subset.set_data
    end
  end

  before_destroy :destroy_attachment, on: :delete
  after_destroy_commit :destroy_report_events, on: :delete

  # after_commit :validate_report_job, unless: :normal_report?

  # def validate_report_job
  #   ValidationJob.perform_later(self)
  # end

  def destroy_report_events
    DestroyEventsJob.perform_later(uid)
  end

  def self.destroy_events(uid, _options = {})
    url = "#{ENV['API_URL']}/events?" + URI.encode_www_form("subj-id" => "#{ENV['API_URL']}/reports/#{uid}")

    # Handle the error so we can have /delete in development.
    begin
      response = Maremma.get url
      events = response.fetch("data", [])
    rescue StandardError
      Rails.logger.info "Exception deleting events for this report - no events for report uid: " + uid.to_s + "."
    end

    # TODO add error class
    # fail "there are no events for this report" if events.is_empty?
    if events && !events.is_empty?
      events.each do |event|
        id = event.fetch("id", nil)
        next if id.is_nil?

        delete_url = "#{ENV['API_URL']}/events/#{id}"
        r = Maremma.delete(delete_url)
        message = r.status == 204 ? "[UsageReports] Event #{id} from report #{uid} was deleted" : "[UsageReports] did not delete #{id}"
        Rails.logger.info message
      end
    else
      Rails.logger.info "there are no events for this report"
    end
  end

  def push_report
    body = { report_id: report_url }

    send_message(body) if ENV["AWS_REGION"].present?
  end

  def compress
    json_report = {
      "report-header":
      {
        "report-name": report_name,
        "report-id": report_id,
        "release": release,
        "created": created,
        "created-by": created_by,
        "reporting-period": reporting_period,
        "report-filters": report_filters,
        "report-attributes": report_attributes,
        "exceptions": exceptions,
      },
      "report-datasets": report_datasets,
    }

    ActiveSupport::Gzip.compress(json_report.to_json)
  end

  def self.compressed_report?
    # check for data sets !empty
    return nil if exceptions.empty? || compressed.nil?

    code = exceptions.first.fetch("code", "")

    (code == 69) && (release == "rd1")
=begin
    if code == 69
      true
    end
=end
  end

  def normal_report?
    return nil if compressed_report? || resolution_report? || report_datasets.nil?

    true
  end

  def compressed_report?
    return nil if exceptions&.empty?

    code = exceptions.first.fetch("code", "")

    (code == 69) && (release == "rd1")

  end

  def resolution_report?
    return nil if exceptions&.empty?

    code = exceptions.first.fetch("code", "")

    (code == 69) && (release == "drl")
  end

  # Builds attachment from (rendered) content and saves it.
  def save_as_attachment(content)
    file_name = "#{self.uid}.json"

    # Use Tempfile - so we can handle large amounts of data.
    tmp = File.new("tmp/" + file_name, "w")
    tmp << content
    tmp.flush

    self.attachment_file_name = file_name
    self.update_attributes(:attachment => tmp)

    # Make sure the tmp file is deleted.
    File.delete(tmp)
  end

  # If there is an attachment: loads the file and returns the text.
  def load_attachment
    if attachment.present?
      begin
        content = Paperclip.io_adapters.for(self.attachment).read
      rescue StandardError
        fail "The attachment for this report cannot be found: " + self.attachment.url.to_s
      end
    end
  end

  # If there is a file attachment to this report: loads the report file and sets
  # the correct fields from the report file instead of the database.
  def load_attachment!
    if !attachment.present?
      fail "[UsageReports] All reports should have an attachment." 
    end

    content = load_attachment
    attachment = AttachmentParser.new(content)
    uuid = attachment.uuid

    if uuid.blank?
      fail "[UsageReports] Report-uid missing from attachment."
    end
    if uuid != uid
      fail "[UsageReports] Report-uid does not match attachment uid."
    end

    # set report.compressed from the attachment.
    if compressed_report? || resolution_report?
      report_subset = report_subsets.order("created_at ASC").first
      attachment_subset = attachment.search_subsets(checksum: report_subset.checksum)
      fail "[UsageReports] cannot find gzip for a report-subset" if attachment_subset.blank?

      self.compressed = ::Base64.strict_decode64(attachment.subset_checksum(subset: attachment_subset))
    elsif normal_report?
      Rails.logger.info "SKV - normal report"
    else
      fail "[UsageReports] Unrecognizable report type."
    end

    # Set report datasets from attachment.
    self.report_datasets = attachment.datasets

    # Loop over report_subsets setting report_subset gzip from the attachment.
    self.report_subsets.each do | report_subset |
      attachment_subset = attachment.search_subsets(checksum: report_subset.checksum)

      if attachment_subset.blank?
        fail "[UsageReports] Cannot find report-subset gzip field."
      end

      report_subset.compressed = ::Base64.strict_decode64(attachment.subset_gzip(subset: attachment_subset))
    end

    # Return the same thing as load_attachment, but the report object has been changed.
    content
  end

  def destroy_attachment
    if self.attachment.present?
      self.attachment = nil
    end
  end

  private
  


  # random number that fits into MySQL bigint field (8 bytes)
  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end

  def to_compress
    if compressed.nil? && report_subsets.empty?
      ReportSubset.create(compressed: compress, report_id: uid)
    elsif report_subsets.empty?
      ReportSubset.create(compressed: compressed, report_id: uid)
      # ReportSubset.create(compressed: self.compressed, report_id: self.report_id)
    end
  end

  def clean_datasets
    write_attribute(:report_datasets, []) if compressed_report?
  end

  def set_uid
    return ActionController::ParameterMissing if reporting_period.nil?

    self.uid = SecureRandom.uuid if uid.blank?
    self.report_filters = report_filters.nil? ? [] : report_filters
    self.report_attributes = report_attributes.nil? ? [] : report_attributes
    self.exceptions = exceptions.nil? ? [] : exceptions
    # self.report_id = self.uid
    month = Date.strptime(reporting_period["begin_date"], "%Y-%m-%d").month.to_s
    year = Date.strptime(reporting_period["begin_date"], "%Y-%m-%d").year.to_s
    write_attribute(:month, month)
    write_attribute(:year, year)
  end
end
