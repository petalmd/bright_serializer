# frozen_string_literal: true

module Inflector
  module_function

  # File active_support/core_ext/hash/keys.rb, line 116
  def deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.deep_transform_keys(&block)
    when Array
      object.map { |e| deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  # File active_support/core_ext/hash/deep_transform_values.rb, line 25
  def deep_transform_values_in_object(object, &block)
    case object
    when Hash
      object.deep_transform_values(&block)
    when Array
      object.map { |e| deep_transform_values_in_object(e, &block) }
    else
      yield(object)
    end
  end
end
