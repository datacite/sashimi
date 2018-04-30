module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    def queue_report(options={})
      sqs = Aws::SQS::Client.new(region: ENV["AWS_REGION"])
      # Send a message to a queue.
      queue_name = "#{Rails.env}_usage" 
      
      begin
        queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
      
        # Create a message with three custom attributes: Title, Author, and WeeksOn.
        options = {
          queue_url: queue_url, 
          message_body: {
            report_id: report_id
          },
          message_attributes: {
            "report-id" => {
              string_value: report_id,
              data_type: "String"
            }
          }
        }
        sent_message = sqs.send_message(options)
        if
          Rails.logger.info "Report " + report_id + "  has been queued."
        end
        sent_message
      rescue Aws::SQS::Errors::NonExistentQueue
        Rails.logger.warn "A queue named '#{queue_name}' does not exist."
        exit(false)
      end
    end
  end
end