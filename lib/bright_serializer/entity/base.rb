# frozen_string_literal: true

module BrightSerializer
  module Entity
    class Base
      DEFAULT_DEFINITION = { type: :undefined }.freeze

      # https://swagger.io/specification/v2/?sbsearch=array%20response#schema-object

      def initialize(definition)
        @definition = definition
      end

      def to_h
        parse_ref!
        @definition
      end

      def parse_ref!
        object = nested_hash_value(@definition, :ref)
        return unless object

        relation = "#/definitions/#{object.delete(:ref).split('::').last.downcase}"
        object['$ref'] = relation
      end

      def nested_hash_value(obj, key)
        if obj.respond_to?(:key?) && obj.key?(key)
          obj
        elsif obj.respond_to?(:each)
          r = nil
          obj.find { |*a| r = nested_hash_value(a.last, key) }
          r
        end
      end
    end
  end
end
