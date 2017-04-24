# fastlane-plugin-setup_fragile_tests_for_rescan.gemspec
#
# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/setup_fragile_tests_for_rescan/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-setup_fragile_tests_for_rescan'
  spec.version       = Fastlane::SetupFragileTestsForRescan::VERSION
  spec.author        = 'Lyndsey Ferguson'
  spec.email         = 'ldf.public+github@outlook.com'

  spec.summary       = "Suppress stabile tests so that 'scan' can run the fragile tests again"
  spec.homepage      = "https://github.com/lyndsey-ferguson/setup_fragile_tests_for_rescan/"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w[README.md LICENSE]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'xcodeproj'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.107.0'
end
