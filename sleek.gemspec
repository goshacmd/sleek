# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sleek/version'

Gem::Specification.new do |spec|
  spec.name          = "sleek"
  spec.version       = Sleek::VERSION
  spec.authors       = ["Gosha Arinich"]
  spec.email         = ["me@goshakkk.name"]
  spec.description   = %q{Sleek is a library for doing analytics.}
  spec.summary       = %q{Sleek is a library for doing analytics.}
  spec.homepage      = "http://github.com/goshakkk/sleek"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'mongoid', '~> 3.1'
  spec.add_runtime_dependency 'activesupport', '~> 3.2'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2.13'
  spec.add_development_dependency 'database_cleaner', '~> 0.9'
end
