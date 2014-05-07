$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bundler/setup'
require 'smooth_operator'

Bundler.require :test, :default

Dir.chdir("spec/") do
  Dir["support/**/*.rb"].each { |file| require file }
end
