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
  end
end
