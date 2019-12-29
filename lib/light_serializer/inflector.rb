
class Inflector
  class << self
    def camel(term)
      term.split('_').collect(&:capitalize).join
    end

    def camel_lower(term)
      string = camel(term)
      string[0] = string[0].downcase
      string
    end

    def underscore(camel_cased_word)
      camel_cased_word.gsub!(/(.)([A-Z])/,'\1_\2')
      camel_cased_word.downcase!
      camel_cased_word
    end

    def dash(underscored_word)
      underscored_word.gsub!("_", "-")
    end
  end
end
