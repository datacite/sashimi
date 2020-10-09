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
          "shoryuken_class" => {
            string_value: options[:shoryuken_class],
            data_type: "String",
          },
        },
        message_body: body.to_json,
      }

      sent_message = sqs.send_message(options)
      Rails.logger.info "[UsageUpdateImportWorker] Report " + report_id + "  has been queued." if sent_message.respond_to?("successful")
      sent_message
    end

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
