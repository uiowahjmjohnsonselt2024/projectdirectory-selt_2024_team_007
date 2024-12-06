# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

desc "Run tests with coverage enabled"
task :coverage do
  puts "Running RSpec with coverage..."
  system("COVERAGE=true bundle exec rspec")
  puts "Running Cucumber with coverage..."
  system("COVERAGE=true bundle exec cucumber")
end


Rails.application.load_tasks