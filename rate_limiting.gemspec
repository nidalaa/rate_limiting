# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rate_limiting/version'

Gem::Specification.new do |spec|
  spec.name          = "rate_limiting"
  spec.version       = RateLimiting::VERSION
  spec.authors       = ["Emilia"]
  spec.email         = ["e.andrzejewska@pilot.co"]
  spec.summary       = "Simle rack middelware- for learning purposes"
  spec.description   = "Enable requests limits in a period of time"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
