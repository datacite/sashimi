source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
gem 'bootsnap', '~> 1.2', '>= 1.2.1'
gem 'mysql2'
gem 'dotenv'
gem 'multi_json'
gem 'json', '~> 1.8', '>= 1.8.5'
gem 'oj', '~> 2.18', '>= 2.18.1'
gem 'equivalent-xml', '~> 0.6.0'
gem 'nokogiri', '~> 1.8.1'
gem 'iso8601', '~> 0.9.0'
gem 'maremma', '~> 4.0'
gem "dalli", "~> 2.7.6"
gem 'lograge', '~> 0.10'
gem 'logstash-event', '~> 1.2', '>= 1.2.02'
gem 'logstash-logger', '~> 0.26.1'
gem 'bugsnag', '~> 6.1', '>= 6.1.1'
gem 'librato-rails', '~> 1.4.2'
gem 'active_model_serializers', '~> 0.10.0'
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'
gem 'simple_command'
gem 'kaminari', '~> 1.0', '>= 1.0.1'
gem 'api-pagination'
gem 'cancancan', '~> 2.0'
gem "facets", require: false
gem 'bergamasco', '~> 0.3.10'
gem 'base32-url', '~> 0.3'
gem 'rack-cors', '~> 1.0', '>= 1.0.2', :require => 'rack/cors'
gem 'json-schema'
gem 'shoryuken', '~> 3.2', '>= 3.2.2'
gem "aws-sdk-s3", require: false
gem 'aws-sdk-sqs', '~> 1.3'
gem 'iso_country_codes'
gem 'yajl-ruby', require: 'yajl'
gem "rack-timeout"


group :development, :test do
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end
group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'httplog', '~> 1.0'
end

group :test do
  gem 'capybara'
  gem 'webmock', '~> 3.1'
  gem 'vcr', '~> 3.0.3'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'simplecov'
  gem 'yajl-ruby', require: 'yajl'

  gem 'factory_bot_rails', '~> 4.8', '>= 4.8.2'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
end
