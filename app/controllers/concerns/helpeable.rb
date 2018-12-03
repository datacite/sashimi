module Helpeable
  extend ActiveSupport::Concern

  require 'active_support/core_ext/object/try'
  require 'action_controller'

  included do

    def validate_uuid string
      uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      return true if uuid_regex.match?(string.to_s.downcase)
    end

    def self.permit_recursive_params(params)
      # Rails.logger.info params.inspect
      (params.try(:to_unsafe_h) || params).map do |key, value|
        if value.is_a?(Array)
          if value.first.respond_to?(:map)
            { key => [ permit_recursive_params(value.first) ] }
          else
            { key => [] }
          end
        elsif value.is_a?(Hash)
          { key => permit_recursive_params(value) }
        else
          key
        end
      end
    end

    def subset_exist? report_id, compressed_subset
      checksum = Digest::SHA256.hexdigest(compressed_subset)
      return true if ReportSubset.where(report_id: report_id, checksum: checksum).any?
      false
    end

    def get_month date
      Date.strptime(date,"%Y-%m-%d").month.to_s 
    end

    def get_year date
      Date.strptime(date,"%Y-%m-%d").year.to_s 
    end

    def self.get_em(h)
      h.each_with_object([]) do |(k,v),keys|      
        keys << k
        keys.concat(get_em(v)) if v.is_a? Hash
      end
    end
    
    def self.deep_find(obj, key, nested_key: nil)
      return obj[key] if obj.respond_to?(:key?) && obj.key?(key)
      if obj.is_a? Enumerable
        found = nil
        obj.find { |*a| found = deep_find(a.last, key) }
        if nested_key.present?
          deep_find(found, nested_key)
        else
          found
        end
      end
    end

  end
end