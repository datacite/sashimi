class ReportSerializer < ActiveModel::Serializer
  type 'report'

  attributes :id, :report_name, :report_id, :created_by, :report_datasets

  def id
    object.uid
  end
end
