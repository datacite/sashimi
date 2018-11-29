require 'digest'
require 'base32/url'

class ReportSubset < ApplicationRecord
  belongs_to :report, primary_key: "uid", foreign_key: "report_id"

  validates_presence_of  :report_id
  after_validation :make_checksum
  before_create :set_id


  def compressed
    # return nil if self.compressed.nil? # Base64.strict_encode64(self.compressed)
    "this should be compressed"
  end


  def make_checksum
    write_attribute(:checksum, Digest::SHA256.hexdigest(self.compressed))
  end

  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end

 

end
