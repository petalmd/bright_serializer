# frozen_string_literal: true

module BrightSerializer
  class Attribute
    attr_reader :key, :block, :condition
    attr_accessor :transformed_key

    def initialize(key, condition, &block)
      @key = key
      @condition = condition
      @block = block
    end

    def serialize(object, params)
      return unless object

      if @block
        @block.arity.abs == 1 ? object.instance_eval(&@block) : object.instance_exec(object, params, &@block)
      elsif object.is_a?(Hash)
        object[key]
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
