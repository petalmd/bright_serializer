# frozen_string_literal: true

module BrightSerializer
  class AttributeRelation < Attribute
    def initialize(key, serializer, params, condition, entity, &block)
      @serializer = serializer
      @params = params || {}

      super(key, condition, entity, &block)
    end

    def serialize(serializer_instance, object, params)
      return unless object

      merged_params = (params || {}).merge(@params)
      value = attribute_value(serializer_instance, object, merged_params)

      class_serializer.new(value, params: merged_params).serializable_hash
    end

    private

    def class_serializer
      @class_serializer ||= @serializer.is_a?(String) ? Inflector.constantize(@serializer) : @serializer
    end
  end
end
