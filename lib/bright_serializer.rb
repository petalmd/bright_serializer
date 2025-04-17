# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/deep_transform_values'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'
require_relative 'bright_serializer/version'

module BrightSerializer
  require_relative 'bright_serializer/serializer'
end
