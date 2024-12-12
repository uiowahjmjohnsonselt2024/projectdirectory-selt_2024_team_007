source "https://rubygems.org"

ruby "3.3.4"

# Bundle edge Rai ls instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.0"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 1.4"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"
gem 'actioncable', '~> 7.0'

gem 'haml-rails', '~> 2.0'

# This is for 3rd-party login(Google login in this case)
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# The two gem is to do country_code and currency_name conversion
gem 'money-rails'
gem 'countries'

# To do the https mock request, not sure if it will be used in deployment
gem 'webmock'

# Manage environment variable
gem 'dotenv-rails', groups: [:development, :test]

gem 'sassc-rails'
gem 'bootstrap', '~> 5.3.3'
gem 'popper_js', '~> 2.11.8'
gem 'jquery-rails'

gem "ruby-openai"


# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "letter_opener"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails"
  gem "simplecov"
  gem "shoulda-matchers"
  gem "rails-controller-testing"
  gem "rspec", "~>3.5"
  gem "guard-rspec"
  gem "rspec-expectations"
  gem "cucumber-rails", "~> 3.0", require: false
  gem "database_cleaner"
  gem "database_cleaner-active_record"
  gem 'factory_bot_rails'
  gem 'rack_session_access'
end

group :production do
  gem 'aws-sdk-s3', '~> 1.0', require: false
  gem "pg" # for Heroku deployment
  gem 'rails_12factor' # for heroku dep
end

group :development, :test do
  gem 'faker'
end
