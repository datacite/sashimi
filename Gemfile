source "https://rubygems.org"

gem "rails", "~> 7.1", ">= 7.1.3"
gem "bootsnap", "~> 1.4", ">= 1.4.4", require: false
gem "mysql2", "~> 0.5.3"
gem "dotenv"
gem "oj", ">= 2.8.3"
gem "oj_mimic_json", "~> 1.0", ">= 1.0.1"
gem "equivalent-xml", "~> 0.6.0"
gem "nokogiri", "~> 1.16", ">= 1.16.4"
gem "iso8601", "~> 0.12.1"
gem "maremma", "~> 5.0"
gem "dalli", "~> 3.2", ">= 3.2.8"
gem "lograge", "~> 0.14.0"
gem "logstash-event", "~> 1.2", ">= 1.2.02"
gem "logstash-logger", "~> 0.26.1"
gem "active_model_serializers", "~> 0.10.10"
gem "jwt"
gem "bcrypt", "~> 3.1.13"
gem "simple_command"
gem "kaminari", "~> 1.2"
gem "api-pagination"
gem "cancancan", "~> 3.5"
gem "facets", require: false
gem "base32-url", "~> 0.3"
gem "rack-cors", "~> 1.0", :require => "rack/cors"
gem "json-schema", "~> 2.8", ">= 2.8.1"
gem "shoryuken", "~> 3.2", ">= 3.2.2"
gem "aws-sdk-s3", require: false
gem "aws-sdk-sqs", "~> 1.22"
gem "iso_country_codes"
gem "sentry-raven", "~> 3.1", ">= 3.1.2"
gem "git", "~> 1.5"
gem "sprockets", "~> 3.7", ">= 3.7.2"
gem "kt-paperclip", "~> 6.4.1"

group :development, :test do
  gem "rspec-rails", "~> 6.1", ">= 6.1.1"
  gem "rubocop-rspec", "~> 2.0", require: false
  gem "rubocop", "~> 1.3", ">= 1.3.1"
  gem "rubocop-performance", "~> 1.5", ">= 1.5.1"
  gem "rubocop-rails", "~> 2.8", ">= 2.8.1"
  gem "binding_of_caller"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "listen", "~> 3.9"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara"
  gem "webmock", "~> 3.1"
  gem "hashdiff", [">= 1.0.0.beta1", "< 2.0.0"]
  gem "vcr", "~> 3.0.3"
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "simplecov"
  gem "factory_bot_rails", "~> 4.8", ">= 4.8.2"
  gem "shoulda-matchers", "~> 3.1"
  gem "faker"
  gem "database_cleaner"
  gem "database_cleaner-active_record", "~> 2.1"
end
