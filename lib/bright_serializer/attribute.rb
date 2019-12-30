# frozen_string_literal: true

module BrightSerializer
  class Attribute
    attr_reader :key, :block, :condition

    def initialize(key, condition, &block)
      @key = key
      @condition = condition
      @block = block
    end

    def serialize(object, params)
      if @block
        object.instance_exec(object, params, &@block)
      else
        object.send(key)
      end
    end

    def condition?(object, params)
      return true unless @condition

      @condition.call(object, params)
    end
  end
end
