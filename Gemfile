source "https://rubygems.org"

ruby "3.3.1"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

gem 'redis', '~> 5.2'
gem 'sidekiq', '~> 7.2', '>= 7.2.4'
gem 'sidekiq-scheduler', '~> 5.0', '>= 5.0.3'
gem 'foreman'

gem 'active_model_serializers'

gem 'guard'
gem 'guard-livereload', require: false

gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'rswag-specs'
end

group :development do
end

group :test do 
  gem 'simplecov', require: false
  gem 'rspec-rails', '~> 6.1.0'
  gem 'rspec-sidekiq'
  gem 'factory_bot_rails'
end
