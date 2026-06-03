# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.release = "sashimi:" + Sashimi::Application::VERSION
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.rails.report_rescued_exceptions = true
  config.enabled_environments = %w(stage production)
  config.send_default_pii = true
  config.environment = Rails.env
end
