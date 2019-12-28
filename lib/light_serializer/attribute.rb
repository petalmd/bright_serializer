
module LightSerializer
  class Attribute
    attr_reader :key, :block, :condition

    def initialize(key, condition, &block)
      @key = key
      @condition = condition
      @block = block
    end

    def condition?(object, params)
      return true unless @condition

      @condition.call(object, params)
    end
  end
end
