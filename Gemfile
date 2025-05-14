# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.1'
gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'
gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'foreman'
gem 'redis', '~> 5.2'
gem 'sidekiq', '~> 7.2', '>= 7.2.4'
gem 'sidekiq-scheduler', '~> 5.0', '>= 5.0.3'

gem 'active_model_serializers'

gem 'guard'
gem 'guard-livereload', require: false

gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'pry-byebug'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development do
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.1.0'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
end
