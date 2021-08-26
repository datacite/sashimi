Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # don't use debug level
  config.log_level = :error

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :dalli_store


  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  # config.action_mailer.perform_caching = false

  config.active_job.queue_adapter = :inline

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Store uploaded files on the local file system in a temporary directory.
  # config.active_storage.service = :test

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

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
