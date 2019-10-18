source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
gem 'bootsnap', '~> 1.4'
gem 'mysql2'
gem 'dotenv'
gem 'multi_json'
gem 'json', '~> 2.2'
gem 'oj', '~> 3.9'
gem 'equivalent-xml', '~> 0.6.0'
gem 'nokogiri', '~> 1.10.4'
gem 'iso8601', '~> 0.12.1'
gem 'maremma', '~> 4.4'
gem "dalli", "~> 2.7.6"
gem 'lograge', '~> 0.11'
gem 'logstash-event', '~> 1.2', '>= 1.2.02'
gem 'logstash-logger', '~> 0.26.1'
gem 'active_model_serializers', '~> 0.10.10'
gem 'jwt'
gem 'bcrypt', '~> 3.1.13'
gem 'simple_command'
gem 'kaminari', '~> 1.0', '>= 1.0.1'
gem 'api-pagination'
gem 'cancancan', '~> 3.0'
gem "facets", require: false
gem 'bergamasco', '~> 0.3.10'
gem 'base32-url', '~> 0.3'
gem 'rack-cors', '~> 1.0', :require => 'rack/cors'
gem 'json-schema', '~> 2.8', '>= 2.8.1'
gem 'shoryuken', '~> 5.0'
gem "aws-sdk-s3", require: false
gem 'aws-sdk-sqs', '~> 1.22'
gem 'iso_country_codes'
gem 'yajl-ruby', require: 'yajl'
# gem "rack-timeout"
gem 'sentry-raven', '~> 2.9'
gem 'git', '~> 1.5'


group :development, :test do
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop-rspec', '~> 1.35'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'httplog', '~> 1.3'
end

group :test do
  gem 'capybara'
  gem 'webmock', '~> 3.1'
  gem 'hashdiff', ['>= 1.0.0.beta1', '< 2.0.0']
  gem 'vcr', '~> 3.0.3'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'simplecov'
  gem 'factory_bot_rails', '~> 4.8', '>= 4.8.2'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
end
