# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

# kt-paperclip global defaults - note bucket is different per environment.
config.paperclip_defaults = {
  storage: :s3,
  s3_protocol: "https",
  # s3_host_alias: 's3-eu-west-1.amazonaws.com',
  s3_credentials: {
    access_key_id: ENV["AWS_ACCESS_KEY_ID"].to_s,
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"].to_s,
    s3_region: ENV["AWS_REGION"] || "eu-west-1",
  },
  bucket: ENV["AWS_S3_BUCKET"] || "metrics-api.test.datacite.org",
  path: "/report_files/:filename",
  url: ":s3_domain_url",
  use_timestamp: false,
}
end
