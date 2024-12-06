require 'cucumber/rails'


WebMock.disable_net_connect!(allow_localhost: true)
Capybara.default_driver = :rack_test

# Ensure transactional fixtures are used for speed
ActionController::Base.allow_rescue = false
# Ensure the test database is clean
begin
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with(:truncation)
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Start DatabaseCleaner before each scenario
Before do
  DatabaseCleaner.start
end

# Clean the database after each scenario
After do
  DatabaseCleaner.clean
end