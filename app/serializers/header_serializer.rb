class HeaderSerializer < ActiveModel::Serializer
  type 'report'

  attributes  :id, :report_header

  def id
    object.uid
  end

  def report_header
    {
      :report_name => object.report_name,
      :report_id => object.report_id,
      :release => object.release,
      :created_by => object.created_by,
      :created => object.created,
      :reporting_period => object.reporting_period, 
      :report_filters=> object.report_filters, 
      :report_attributes => object.report_attributes,
      :exceptions => object.exceptions
    }
  end

end
