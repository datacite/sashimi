# frozen_string_literal: true

Raven.configure do |config|
  config.environments = %w(stage production)
  config.dsn = ENV["SENTRY_DSN"]
  config.release = "sashimi:" + Sashimi::Application::VERSION
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
