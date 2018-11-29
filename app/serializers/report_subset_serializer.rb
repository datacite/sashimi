class ReportSubsetSerializer < ActiveModel::Serializer
  # type 'report_subset'

  attributes :gzip, :checksum

  def gzip
    object.gzip
  end

end
