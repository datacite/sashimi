ENV['RAILS_ENV'] = 'test'
ENV['USAGE_URL'] = "https://api.stage.datacite.org"
ENV['API_URL'] = "https://api.stage.datacite.org"
# set up Code Climate
require 'simplecov'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require "rspec/rails"
require "shoulda-matchers"
require "webmock/rspec"
require "rack/test"
require "database_cleaner"

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP']],
  allow_localhost: true
)

# configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # add `FactoryBot` methods
  config.include FactoryBot::Syntax::Methods

  config.include JobHelper, type: :job

  # don't use transactions, use database_clear gem via support file
  config.use_transactional_fixtures = false

  # add custom json method
  config.include RequestSpecHelper, type: :request

  ActiveJob::Base.queue_adapter = :test

  ## To do: find another way to track and delete test files.
  ## Dev/Test/Stage- {Rails.root}/public/report_files.
  ## Production - AWS S3 BUCKET (report_files directory)
  # Cleans up generated reports files after test run.
  # Make sure we are not doing this in production.
  config.after(:each) do # :suite or :each or :all
    # Never delete files in production. This is dangerous, should find another way to clean up.
    if Rails.env.development? || Rails.env.test? || Rails.env.stage?
      Dir["#{Rails.root}/public/report_files/**"].each do |file|
          # File.delete(file)
      end
    end
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.configure_rspec_metadata!
  c.default_cassette_options = { :match_requests_on => [:method, :path] }
end

