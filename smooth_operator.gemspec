# coding: utf-8

lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'smooth_operator/version'

Gem::Specification.new do |spec|
  spec.name          = "smooth_operator"
  spec.version       = SmoothOperator::VERSION
  spec.authors       = ["João Gonçalves"]
  spec.email         = ["goncalves.joao@gmail.com"]
  spec.description   = %q{ActiveResource alternative}
  spec.summary       = %q{Simple and fully customizable alternative to ActiveResource, using faraday gem to stablish parallel remote calls"}
  spec.homepage      = "https://github.com/goncalvesjoao/smooth_operator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler", "~> 1.3"
  
  spec.add_dependency "json"
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'faraday', '~> 0.8.9'
end
