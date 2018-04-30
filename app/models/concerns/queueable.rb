module Queueable
  extend ActiveSupport::Concern

  require 'aws-sdk-sqs'

  included do
    def queue_report(options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      payload = "doi=#{doi}\nurl=#{options[:url]}"
      mds_url = Rails.env.production? ? 'https://mds.datacite.org' : 'https://mds.test.datacite.org' 
      url = "#{mds_url}/doi/#{doi}"

      response = Maremma.put(url, content_type: 'text/plain;charset=UTF-8', data: payload, username: options[:username], password: options[:password])

      if response.status == 201
        Rails.logger.info "[Handle] Updated to URL " + options[:url] + " for DOI " + doi + "."
        response
      else
        Rails.logger.warn "[Handle] Error updating URL " + options[:url] + " for DOI " + doi + "."
        Rails.logger.warn response.body["errors"].inspect
        response
      end
    end
  end
end