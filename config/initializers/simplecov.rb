if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/config/'
    add_filter '/spec/'
    add_filter '/test/'
    add_filter '/app/helpers/'
    add_filter '/app/channels/'
    add_filter '/app/jobs/'
  end
end
