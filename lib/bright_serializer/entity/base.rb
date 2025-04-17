# frozen_string_literal: true

require_relative 'parser'

module BrightSerializer
  module Entity
    class Base
      DEFAULT_DEFINITION = { type: :undefined }.freeze

      # https://swagger.io/specification/v2/?sbsearch=array%20response#schema-object

      def initialize(definition)
        @definition = definition
      end

      def to_h
        @definition = Inflector.deep_transform_keys_in_object(@definition) { |k| k.to_s.camelize(:lower) }
        parse_ref!
        evaluate_callable!
        @definition
      end

      def parse_ref!
        object = nested_hash(@definition, 'ref')
        return unless object

        ref_entity_name = object.delete('ref').constantize.entity_name
        relation = "#/definitions/#{ref_entity_name}"
        object['$ref'] = relation
      end

      def evaluate_callable!
        @definition = Inflector.deep_transform_values_in_object(@definition) do |value|
          value.respond_to?(:call) ? value.call : value
        end
      end

      def nested_hash(obj, key)
        if obj.respond_to?(:key?) && obj.key?(key)
          obj
        elsif obj.respond_to?(:each)
          r = nil
          obj.find { |*a| r = nested_hash(a.last, key) }
          r
        end
      end
    end
  end
end
