class ReportFullSubsetSerializer < ActiveModel::Serializer
  type 'report'

  attributes :id, :report_header, :report_datasets, :report_subsets, :exceptions

  def id
    object.report_id
  end

  def gzip
    #object.gzip
    @instance_options[:gzip]
  end

  def report_subsets
    #[{gzip: object.gzip, checksum: object.checksum}]
    [{gzip: @instance_options[:gzip], checksum: object.checksum}]
  end

  def report_datasets
    []
  end

  def report_header
    @instance_options[:report_header]
  end
end
