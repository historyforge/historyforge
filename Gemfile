# frozen_string_literal: true

source 'https://rubygems.org'
ruby '4.0.6'

gem 'activerecord-precounter'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'airbrake'
gem 'ancestry'
gem 'ar_doc_store'
gem 'benchmark'
gem 'bootsnap', require: false
gem 'brakeman', require: false
gem 'cancancan'
gem 'chartkick'
gem 'devise'
gem 'devise-bootstrap-views', '~> 1.0'
# Version 3 requires migrating invitation data from users to devise_invitations.
gem 'devise_invitable', '~> 2.0.12'
gem 'devise-passkeys'
gem 'dotenv-rails'
gem 'fast_memoize'
gem 'geocoder'
gem 'image_processing'
gem 'jbuilder', '~> 2.0'
# Rails 8.1 passes JSON.parse options as a positional hash; JSON 3 requires keywords.
gem 'json', '< 3'
gem 'jsbundling-rails'
gem 'kaminari'
gem 'liquid'
gem 'omniauth-facebook'
gem 'omniauth-rails_csrf_protection'
gem 'ostruct'
gem 'paper_trail'
gem 'pg'
gem 'pg_search'
gem 'pretender'
gem 'puma'
gem 'rack-cors'
gem 'rails', '~> 8.0'
gem 'rails_autolink'
gem 'ransack'
gem 'turbo-rails'
gem 'recaptcha'
gem 'ruby-vips'
gem 'sassc'
gem 'simple_form'
gem 'slim'
gem 'sprockets-rails'

group :development do
  gem 'annotate'
  gem 'byebug'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'parallel', require: false
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp', '>= 0.26.9', require: false
  gem 'ruby-progressbar', require: false
  gem 'simplecov', require: false
  # gem 'standard'
  gem 'web-console'
end

group :development, :test do
  gem 'amazing_print'
  gem 'bullet', require: ENV['BULLET'] == '1'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'faker'
end
