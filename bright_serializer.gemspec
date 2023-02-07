# frozen_string_literal: true

require 'bright_serializer/version'

Gem::Specification.new do |spec|
  spec.name          = 'bright_serializer'
  spec.version       = BrightSerializer::VERSION
  spec.authors       = ['Jean-Francis Bastien']
  spec.email         = ['jfbastien@petalmd.com']

  spec.summary       = 'Light and fast Ruby serializer'
  spec.description   = 'BrightSerializer is a minimalist implementation serializer for Ruby objects.'
  spec.homepage      = 'https://github.com/petalmd/bright_serializer'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'changelog_uri' => 'https://github.com/petalmd/bright_serializer/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/petalmd/bright_serializer',
    'bug_tracker_uri' => 'https://github.com/petalmd/bright_serializer/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['LICENSE.txt', 'README.md', 'config/**/*', 'lib/**/*']
  spec.extra_rdoc_files = %w[LICENSE.txt README.md]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oj', '~> 3'
  spec.add_development_dependency 'activesupport', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'faker', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
