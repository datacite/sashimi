module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    # shoryuken_class is needed for the consumer to process the message
    # we use the AWS SQS client directly as there is no consumer in this app
    def send_message(body, options={})
      sqs = Aws::SQS::Client.new
      queue_url = sqs.get_queue_url(queue_name: "#{Rails.env}_usage").queue_url
      options[:shoryuken_class] ||= "UsageUpdateImportWorker"

      options = {
        queue_url: queue_url,
        message_attributes: {
          'shoryuken_class' => {
            string_value: options[:shoryuken_class],
            data_type: 'String'
          },
        },
        message_body: body.to_json,
      }

      sqs.send_message(options)
    end

    # def queue_report(options={})
    #   queue_name = "#{Rails.env}_usage"
    #   queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
    #   options[:shoryuken_class] ||= "UsageUpdateImportWorker"

    #   begin
    #     # Create a message with three custom attributes: Title, Author, and WeeksOn.
    #     body = { report_id: report_url }.to_json
    #     options = {
    #       queue_url: queue_url, 
    #       message_body: body,
    #       message_attributes: {
    #         "report_id" => {
    #           string_value: report_url,
    #           data_type: "String"
    #         },
    #         'shoryuken_class' => {
    #           string_value: options[:shoryuken_class],
    #           data_type: 'String'
    #         }
    #       }
    #     }
    #     sent_message = sqs.send_message(options)

    #     if sent_message.respond_to?("successful")
    #       Rails.logger.debug "[UsageUpdateImportWorker] Report " + report_id + "  has been queued."
    #     end

    #     sent_message
    #     true
    #   rescue Aws::SQS::Errors::NonExistentQueue
    #     logger.error "[UsageUpdateImportWorker] A queue named '#{queue_name}' does not exist."
    #     false
    #   end
    # end

    # def queue_report_subset(options = {})
    #   queue_name = "#{Rails.env}_usage"
    #   queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
    #   options[:shoryuken_class] ||= "UsageUpdateImportWorker"
  
    #   begin
    #     # Create a message with three custom attributes: Title, Author, and WeeksOn.
    #     body = { report_id: report_subset_url }.to_json
    #     options = {
    #       queue_url: queue_url, 
    #       message_body: body,
    #       message_attributes: {
    #         "report_id" => {
    #           string_value: report_subset_url,
    #           data_type: "String"
    #         },
    #         'shoryuken_class' => {
    #           string_value: options[:shoryuken_class],
    #           data_type: 'String'
    #         }
    #       }
    #     }
    #     sent_message = sqs.send_message(options)
    #     Rails.logger.debug "[UsageUpdateImportWorker] response: " + sent_message.inspect 
    #     if sent_message.respond_to?("successful")
    #       Rails.logger.debug "[UsageUpdateImportWorker] Report " + report_id + "  has been queued."
    #     end
    #     true
    #   rescue Aws::SQS::Errors::NonExistentQueue
    #     Rails.logger.error "[UsageUpdateImportWorker] A queue named '#{queue_name}' does not exist."
    #     false
    #   end
    # end

    def report_url
      "#{ENV['USAGE_URL']}/reports/#{uid}"
    end

    def report_subset_url
      "#{ENV['USAGE_URL']}/report-subsets/#{id}"
    end

    def sqs
      Aws::SQS::Client.new(region: ENV["AWS_REGION"])
    end
  end
end
