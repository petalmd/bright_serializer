# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/petalmd/bright_serializer'
    spec.metadata['changelog_uri'] = 'https://github.com/petalmd/bright_serializer/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|.github)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oj', '~> 3'
  spec.add_development_dependency 'activesupport', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'faker', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
