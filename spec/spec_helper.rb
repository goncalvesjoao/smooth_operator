require 'simplecov'

SimpleCov.start do
  root('lib/')
  project_name('SmoothOperator')
  coverage_dir('../tmp/coverage/')
end

require 'require_helper'

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.include PersistenceHelper, helpers: :persistence

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  LocalhostServer.new(TestServer.new, 4567)

end
