module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    def queue_report(options={})
      queue_name = "#{Rails.env}_usage" 
      Rails.logger.info "Trigger queue for" + report_id
      # sqs = Aws::SQS::Client.new(region: ENV["AWS_REGION"])
      queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
  
      begin
        # Create a message with three custom attributes: Title, Author, and WeeksOn.
        body = { report_id: report_url }.to_json
        options = {
          queue_url: queue_url, 
          message_body: body,
          message_attributes: {
            "report-id" => {
              string_value: report_url,
              data_type: "String"
            }
          }
        }
        sent_message = sqs.send_message(options)
        Rails.logger.info "response: " + sent_message.inspect 
        if sent_message.respond_to?(successful)
          Rails.logger.info "Report " + report_id + "  has been queued."
        end
        sent_message
      rescue Aws::SQS::Errors::NonExistentQueue
        Rails.logger.warn "A queue named '#{queue_name}' does not exist."
        exit(false)
      end
    end

    def report_url
      "https://metrics.test.datacite.org/reports/#{uid}"
    end

    def sqs
      Aws::SQS::Client.new(region: ENV["AWS_REGION"])
    end
  end
end


