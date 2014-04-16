$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bundler'

Bundler.setup

require 'rspec'
require 'pry'
# require 'webmock/rspec'
require 'smooth_operator'

Dir.chdir("spec/") do
  Dir["support/models/*.rb"].each { |file| require file }
end


RSpec.configure do |config|
  #config.treat_symbols_as_metadata_keys_with_true_values = true
  #config.filter_run :current
  
  # see: https://github.com/bmabey/database_cleaner#rspec-example
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.clean_with(:truncation)
  # end

  # config.before(:each) do
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
end
