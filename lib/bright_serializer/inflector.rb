# frozen_string_literal: true

class Inflector
  CAMEL_REGEX = /(_[a-zA-Z])/.freeze
  UNDERSCORE_REGEX = /(.)([A-Z])/.freeze

  class << self
    def camel(term)
      return term.capitalize! unless term.include?('_')

      term.capitalize!
      term.gsub!(CAMEL_REGEX) { Regexp.last_match(1).delete('_').upcase! }
    end

    def camel_lower(term)
      return term unless term.include?('_')

      term.gsub!(CAMEL_REGEX) { Regexp.last_match(1).delete('_').upcase! }
    end

    def underscore(camel_cased_word)
      camel_cased_word.gsub!(UNDERSCORE_REGEX, '\1_\2')
      camel_cased_word.downcase!
      camel_cased_word
    end

    def dash(underscored_word)
      underscored_word.tr!('_', '-')
      underscored_word
    end

    # File activesupport/lib/active_support/inflector/methods.rb, line 271
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')

      # Trigger a built-in NameError exception including the ill-formed constant in the message.
      Object.const_get(camel_cased_word) if names.empty?

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.each_with_object(constant) do |ancestor, const|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end

    # File active_support/core_ext/hash/keys.rb, line 116
    def deep_transform_keys_in_object(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = deep_transform_keys_in_object(value, &block)
        end
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
        object.transform_values { |value| deep_transform_values_in_object(value, &block) }
      when Array
        object.map { |e| deep_transform_values_in_object(e, &block) }
      else
        yield(object)
      end
    end
  end
end
