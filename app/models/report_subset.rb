require 'digest'
require 'base32/url'

class ReportSubset < ApplicationRecord
  belongs_to :report, primary_key: "uid", foreign_key: "report_id"

  # validates_presence_of :compressed, :report_id
  after_validation :make_checksum
  before_create :set_id

  # attr_accessor :compressed

  def compressed
    # Base64.strict_encode64(self.compressed)
    "this should be compressed"
  end


  # private

  def make_checksum
    write_attribute(:checksum, Digest::SHA256.hexdigest(self.compressed))
  end

  def set_id
    self.id = SecureRandom.random_number(9223372036854775807)
  end

 

end
