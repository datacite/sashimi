class ReportSubsetSerializer < ActiveModel::Serializer
  # type 'report_subset'

  attributes :gzip, :checksum

  def gzip
    object.compressed
  end

end
