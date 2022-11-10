# frozen_string_literal: true

module BrightSerializer
  class AttributeRelation < Attribute
    def initialize(key, serializer, condition, entity, options, &block)
      @serializer = serializer
      @options = options || {}

      add_entity_ref!(entity)
      super(key, condition, entity, &block)
    end

    def serialize(serializer_instance, object, params)
      return unless object

      merged_params = nil
      merged_params = (params || {}).merge(@options[:params] || {}) if params || @options[:params]
      value = attribute_value(serializer_instance, object, merged_params)

      class_serializer.new(value, params: merged_params, **@options).serializable_hash
    end

    private

    def class_serializer
      @class_serializer ||= @serializer.is_a?(String) ? Inflector.constantize(@serializer) : @serializer
    end

    def add_entity_ref!(entity)
      return unless entity

      if entity[:type].to_sym == :object && entity[:ref].nil?
        entity[:ref] = @serializer
      elsif entity[:type].to_sym == :array && entity.dig(:items, :ref).nil?
        entity[:items] ||= {}
        entity[:items][:ref] = @serializer
      end
    end
  end
end
