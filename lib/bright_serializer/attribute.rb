# frozen_string_literal: true

require_relative 'entity/base'

module BrightSerializer
  class Attribute
    attr_reader :key, :block, :condition, :entity
    attr_accessor :transformed_key

    def initialize(key, condition, entity, &block)
      @key = key
      @condition = condition
      @block = block
      @entity = entity ? Entity::Base.new(entity) : nil
    end

    def serialize(serializer_instance, object, params)
      return unless object

      value = attribute_value(serializer_instance, object, params)

      value.respond_to?(:serializable_hash) ? value.serializable_hash : value
    end

    def condition?(object, params)
      return true unless @condition

      @condition.call(object, params)
    end

    private

    def attribute_value(serializer_instance, object, params)
      if @block
        if @block.arity.abs == 1
          serializer_instance.instance_exec(object, &@block)
        else
          serializer_instance.instance_exec(object, params, &@block)
        end
      elsif object.is_a?(Hash)
        object.key?(key) ? object[key] : object[key.to_s]
      else
        object.public_send(key)
      end
    end
  end
end
