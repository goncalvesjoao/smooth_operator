$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bundler'
require 'smooth_operator'

Bundler.require :test, :default

Dir.chdir("spec/") do
  Dir["support/**/*.rb"].each { |file| require file }
end

include WebMock::API
# WebMock.allow_net_connect!

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    stub_request(:any, /localhost/).to_rack(FakeServer)
  end

end
