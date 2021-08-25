# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in bright_serializer.gemspec
gemspec

gem 'oj', require: false

group :test do
  gem 'coveralls_reborn', require: false # https://github.com/lemurheavy/coveralls-ruby/issues/163
  gem 'faker'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end
