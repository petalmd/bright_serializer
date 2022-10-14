# frozen_string_literal: true

module BrightSerializer
  class AttributeRelation < Attribute
    ##
    # Just like attributes: fields, entity, if, params
    # options should only have `fields` left
    def initialize(key, serializer, condition, entity, options, &block)
      @serializer = serializer
      @options = options

      super(key, condition, entity, &block)
    end

    def serialize(serializer_instance, object, params)
      return unless object

      merged_params = nil
      if params || @options[:params]
        merged_params = (params || {}).merge(@options[:params] || {})
      end
      value = attribute_value(serializer_instance, object, merged_params)

      class_serializer.new(value, params: merged_params, **@options).serializable_hash
    end

    private

    def class_serializer
      @class_serializer ||= @serializer.is_a?(String) ? Inflector.constantize(@serializer) : @serializer
    end
  end
end
