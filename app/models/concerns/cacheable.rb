module Cacheable
  extend ActiveSupport::Concern

  included do
    def cached_reports_count(id)
      if Rails.application.config.action_controller.perform_caching
        Rails.cache.fetch("cached_reports_count/#{id}", expires_in: 24.hours) do
          Report.where(client_id: id).count
        end
      else
        Report.where(client_id: id).count
      end
    end

    def cached_client_count
      if Rails.application.config.action_controller.perform_caching
        Rails.cache.fetch("cached_client_count", expires_in: 24.hours) do
          Report.group(:client_id).count
        end
      else
        Report.group(:client_id).count
      end
    end

    def cached_created_by_count(id, options={})
      if Rails.application.config.action_controller.perform_caching
        Rails.cache.fetch("created_by_count/#{id}", expires_in: 24.hours) do
          Report.where(client_id: id).group(:created_by).count
        end
      else
        Report.where(client_id: id).group(:created_by).count
      end
    end

    def cached_year_count(id)
      if Rails.application.config.action_controller.perform_caching
        Rails.cache.fetch("cached_year_count/#{id}", expires_in: 24.hours) do
          Report.where(client_id: id).group(:year).count
        end
      else
        Report.where(client_id: id).group(:year).count
      end
    end

    def cached_report_id_count(id, options={})
      if Rails.application.config.action_controller.perform_caching
        Rails.cache.fetch("cached_report_id_count/#{id}", expires_in: 24.hours) do
          Report.where(client_id: id).group(:release).count
        end
      else
        Report.where(client_id: id).group(:release).count
      end
    end


  end
end
