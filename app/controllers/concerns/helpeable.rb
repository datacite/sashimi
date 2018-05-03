module Helpeable
  extend ActiveSupport::Concern

  require 'active_support/core_ext/object/try'
  require 'action_controller'

  included do

    def self.permit_recursive_params(params)
      Rails.logger.info "ccjhchch"
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