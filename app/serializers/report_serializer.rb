class ReportSerializer < ActiveModel::Serializer
  type 'report'

  attributes  :id, :report_header, :report_datasets

  def id
    object.uid
  end

  def report_header
    {
      :report_name => object.report_name,
      :report_id => object.report_id,
      :created_by => object.created_by,
      :created => object.created
    }
  end
end
