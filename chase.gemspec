# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chase/version'

Gem::Specification.new do |spec|
  spec.name          = 'chase'
  spec.version       = Chase::VERSION
  spec.authors       = ['Joe Osburn']
  spec.email         = ['joe@jnodev.com']

  spec.summary       = 'Chase is an event machine http server'
  spec.homepage      = 'https://github.com/joeosburn/chase'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.bindir        = 'bin'
  # spec.executables   = ['cannon', 'cannon-dev']
  spec.require_paths = ['lib']
  spec.test_files = Dir['spec/**/*']

  spec.add_dependency 'eventmachine', '~> 1.2.0'

  spec.add_development_dependency 'rspec', '~> 3.5.0'
end
