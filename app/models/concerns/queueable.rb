module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    def queue_report(options={})
      queue_name = "#{Rails.env}_usage" 
      if ENV["AWS_REGION"] 
        sqs = Aws::SQS::Client.new(region: ENV["AWS_REGION"])
        queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
      else
        queue_url = "usage"
      end
    
      # Create a message with three custom attributes: Title, Author, and WeeksOn.
      {
        queue_url: queue_url, 
        message_body: {
          report_id: report_url
        },
        message_attributes: {
          "report-id" => {
            string_value: report_url,
            data_type: "String"
          }
        }
      }.to_json
      # sent_message = sqs.send_message(options)
    end

    def report_url
      "https://metrics.test.datacite.org/reports/"+report_id
    end
  end
end