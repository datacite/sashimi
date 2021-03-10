class ReportAttachmentSerializer < ActiveModel::Serializer
    type 'report'
  
    attributes  :id, :report_header, :report_datasets, :report_subsets

    def report_subsets
        attachment = instance_options[:report_attachment]    
        report_subsets = attachment["report"]["report-subsets"]
    end
    
    def id
      object.uid
    end

    def report_header
      {
        :report_name => object.report_name,
        :report_id => object.report_id,
        :client_id => object.user_id,
        :year => object.year,
        :month => object.month,
        :release => object.release,
        :created_by => object.created_by,
        :created => object.created,
        :reporting_period => object.reporting_period, 
        :report_filters=> object.report_filters, 
        :report_attributes => object.report_attributes,
        :exceptions => object.exceptions, 
      }
    end
end