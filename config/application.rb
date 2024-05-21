require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

# load ENV variables from container environment if json file exists
# see https://github.com/phusion/baseimage-docker#envvar_dumps
env_json_file = "/etc/container_environment.json"
if File.exist?(env_json_file)
  env_vars = JSON.parse(File.read(env_json_file))
  env_vars.each { |k, v| ENV[k] = v }
end

# default values for some ENV variables
ENV['APPLICATION'] ||= "metrics-api"
ENV['HOSTNAME'] ||= "sashimi"
ENV['MEMCACHE_SERVERS'] ||= "memcached:11211"
ENV['SITE_TITLE'] ||= "DLM API"
ENV['LOG_LEVEL'] ||= "info"
ENV['CONCURRENCY'] ||= "25"
ENV['CDN_URL'] ||= "https://assets.datacite.org"
ENV['DOI_URL'] ||= "https://doi.datacite.org"
ENV['GITHUB_URL'] ||= "https://github.com/datacite/lupo"
ENV['SEARCH_URL'] ||= "https://search.datacite.org/"
ENV['VOLPINO_URL'] ||= "https://profiles.datacite.org/api"
ENV['RE3DATA_URL'] ||= "https://www.re3data.org/api/beta"
ENV['MYSQL_DATABASE'] ||= "metrics"
ENV['MYSQL_USER'] ||= "root"
ENV['MYSQL_PASSWORD'] ||= ""
ENV['MYSQL_HOST'] ||= "mysql"
ENV['MYSQL_PORT'] ||= "3306"
ENV['TRUSTED_IP'] ||= "10.0.40.1"
ENV['LEVRIERO_URL'] ||= "https://api.datacite.org"
ENV['USAGE_URL'] ||= "https://api.datacite.org"
ENV['API_URL'] ||= "https://api.datacite.org"
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= "40"

module Sashimi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.autoload_once_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join("app", "models", "concerns")

    config.eager_load_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("app", "models", "concerns")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    # secret_key_base is not used by Rails API, as there are no sessions
    config.secret_key_base = 'blipblapblup'

    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Logstash.new
    config.lograge.logger = LogStashLogger.new(type: :stdout)
    config.logger = config.lograge.logger
    config.log_level = ENV["LOG_LEVEL"].to_sym

    config.lograge.ignore_actions = ["HeartbeatController#index", "IndexController#index"]

    config.lograge.base_controller_class = "ActionController::API"

    config.lograge.custom_options = lambda do |event|
      exceptions = %w(controller action format id)
      {
        params: event.payload[:params].except(*exceptions),
        uid: event.payload[:uid],
      }
    end

    config.action_dispatch.debug_exception_log_level = :error

    # configure caching
    config.cache_store = :mem_cache_store, ENV["MEMCACHE_SERVERS"], { namespace: ENV["APPLICATION"] }

    # raise error with unpermitted parameters
    config.action_controller.action_on_unpermitted_parameters = :raise

    # compress responses with deflate or gzip
    config.middleware.use Rack::Deflater

    # set Active Job queueing backend
    config.active_job.queue_adapter = ENV["AWS_REGION"] ? :shoryuken : :inline
    config.active_job.queue_name_prefix = Rails.env

    config.generators do |g|
      g.fixture_replacement :factory_bot
    end

    # kt-paperclip global defaults
    config.paperclip_defaults = {
      storage: :filesystem,
      path: ":rails_root/public/report_files/:filename",
      url: "/report_files/:filename",
      use_timestamp: false,
    }

    # https://blog.kiprosh.com/rails-7-1-raises-on-assignment-to-readonly-attributes
    config.active_record.raise_on_assign_to_attr_readonly = false
  end
end
