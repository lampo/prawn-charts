# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prawn/charts/version'

Gem::Specification.new do |spec|
  spec.name          = "prawn-charts"
  spec.version       = Prawn::Charts::VERSION
  spec.authors       = ["Cajun"]
  spec.email         = ["zac@kleinpeter.org"]
  spec.description   = %q{WARNING: Alpha Software.  Charting Lib for Prawn.
  Supports bar, line, and combo charts.  }
  spec.summary       = %q{Prawn Charting Lib}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 1.9.3'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.add_dependency "prawn"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
end
