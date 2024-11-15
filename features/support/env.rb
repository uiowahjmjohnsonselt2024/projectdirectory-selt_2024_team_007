require 'cucumber/rails'
Capybara.default_driver = :rack_test

# Ensure transactional fixtures are used for speed
ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :transaction