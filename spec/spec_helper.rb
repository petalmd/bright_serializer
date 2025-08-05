# frozen_string_literal: true

Warning[:deprecated] = true

require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
    enable_coverage :branch
  end
end

require 'bright_serializer'
require 'faker'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.full_backtrace = true
end
