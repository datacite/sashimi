module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    def queue_report(options={})
      logger = Logger.new(STDOUT)

      queue_name = "#{Rails.env}_usage" 
      logger.info  "[UsageUpdateImportWorker] inside queque #{queue_name}"
      logger.info "[UsageUpdateImportWorker] Trigger queue for " + uid
      queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
      options[:shoryuken_class] ||= "UsageUpdateImportWorker"
  
      begin
        # Create a message with three custom attributes: Title, Author, and WeeksOn.
        body = { report_id: report_url }.to_json
        options = {
          queue_url: queue_url, 
          message_body: body,
          message_attributes: {
            "report_id" => {
              string_value: report_url,
              data_type: "String"
            },
            'shoryuken_class' => {
              string_value: options[:shoryuken_class],
              data_type: 'String'
            }
          }
        }
        sent_message = sqs.send_message(options)
        logger.info "[UsageUpdateImportWorker] response: " + sent_message.inspect 
        if sent_message.respond_to?("successful")
          logger.info "[UsageUpdateImportWorker] Report " + report_id + "  has been queued."
        end
        sent_message
      rescue Aws::SQS::Errors::NonExistentQueue
        logger.warn "[UsageUpdateImportWorker] A queue named '#{queue_name}' does not exist."
        exit(false)
      end
      true
    end

    def queue_report_subset(options={})
      logger = Logger.new(STDOUT)

      queue_name = "#{Rails.env}_usage" 
      logger.info  "[UsageUpdateImportWorker] inside queque #{queue_name}"
      logger.info "[Subset-UsageUpdateImportWorker] Trigger queue for subset #{id}" 
      queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
      options[:shoryuken_class] ||= "UsageUpdateImportWorker"
  
      begin
        # Create a message with three custom attributes: Title, Author, and WeeksOn.
        body = { report_id: report_subset_url }.to_json
        options = {
          queue_url: queue_url, 
          message_body: body,
          message_attributes: {
            "report_id" => {
              string_value: report_subset_url,
              data_type: "String"
            },
            'shoryuken_class' => {
              string_value: options[:shoryuken_class],
              data_type: 'String'
            }
          }
        }
        sent_message = sqs.send_message(options)
        logger.info "[UsageUpdateImportWorker] response: " + sent_message.inspect 
        if sent_message.respond_to?("successful")
          logger.info "[UsageUpdateImportWorker] Report " + report_id + "  has been queued."
        end
        sent_message
      rescue Aws::SQS::Errors::NonExistentQueue
        logger.warn "[UsageUpdateImportWorker] A queue named '#{queue_name}' does not exist."
        exit(false)
      end
      true
    end

    def report_url
      "#{ENV["USAGE_URL"]}/reports/#{uid}"
    end

    def report_subset_url
      "#{ENV["USAGE_URL"]}/report-subsets/#{id}"
    end

    def sqs
      Aws::SQS::Client.new(region: ENV["AWS_REGION"])
    end
  end
end


