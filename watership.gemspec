# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watership/version'

Gem::Specification.new do |spec|
  spec.name          = "watership"
  spec.version       = Watership::VERSION
  spec.authors       = ["Ben Scofield"]
  spec.email         = ["git@turrean.com"]
  spec.summary       = %q{Wrapper around Bunny to better handle connection issues}
  spec.description   = %q{Wrapper around Bunny to better handle connection issues}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency 'bunny'
  spec.add_dependency 'json'
end
