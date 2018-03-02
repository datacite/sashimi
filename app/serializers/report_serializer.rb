class ReportSerializer < ActiveModel::Serializer
  cache key: 'report'
  type 'report'

  attributes :id, :report_name, :report_id, :created_by, :report_datasets

  def id
    object.id
  end

end
