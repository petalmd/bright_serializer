# frozen_string_literal: true

module BrightSerializer
  class AttributeRelation < Attribute
    def initialize(key, class_name, params, condition, entity, &block)
      @class_name = class_name
      @params = params || {}

      super(key, condition, entity, &block)
    end

    def serialize(_serializer_instance, object, params)
      relation = object.is_a?(Hash) ? object[key] : object.public_send(key)
      merged_params = (params || {}).merge(@params)
      class_serializer.new(relation, params: merged_params).serializable_hash
    end

    private

    def class_serializer
      @class_serializer ||= @class_name.is_a?(String) ? Inflector.constantize(@class_name) : @class_name
    end
  end
end
