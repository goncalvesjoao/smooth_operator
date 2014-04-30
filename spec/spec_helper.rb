require 'simplecov'

SimpleCov.start do
  root('lib/')
  project_name('SmoothOperator')
  coverage_dir('../tmp/coverage/')
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bundler'
require 'smooth_operator'

Bundler.require :test, :default

Dir.chdir("spec/") do
  Dir["support/**/*.rb"].each { |file| require file }
end

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.include PersistenceHelper, helpers: :persistence

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  LocalhostServer.new(TestServer.new, 4567)

end
