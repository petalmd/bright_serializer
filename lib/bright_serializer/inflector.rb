# frozen_string_literal: true

class Inflector
  class << self
    def camel(term)
      return term.capitalize! unless term.include?('_')

      term.split('_').map(&:capitalize!).join
    end

    def camel_lower(term)
      return term unless term.include?('_')

      string = camel(term)
      string[0] = string[0].downcase
      string
    end

    def underscore(camel_cased_word)
      camel_cased_word.gsub!(/(.)([A-Z])/, '\1_\2')
      camel_cased_word.downcase!
      camel_cased_word
    end

    def dash(underscored_word)
      underscored_word.tr!('_', '-')
    end
  end
end
