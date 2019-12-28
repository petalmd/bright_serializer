require_relative 'attribute'
require 'oj'

module LightSerializer
  module Serializer
    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(object, **options)
      @object = object
      @params = options[:params]
      @fields = options[:fields]
      @options = options
    end

    def to_hash
      self.class.attributes_to_serialize.each_with_object({}) do |attribute, result|
        p attribute.key
        next unless attribute.condition?(@object, @params)

        result[attribute.key] =
          if attribute.block
            @object.instance_exec(@object, @params, &attribute.block)
          else
            @object.send(attribute.key)
          end
      end
    end

    alias serialize_hash to_hash

    def to_json
      Oj.dump(to_hash)
    end

    alias serialize_json to_json

    module ClassMethods
      attr_reader :attributes_to_serialize

      def attributes(*attributes, **options, &block)
        @attributes_to_serialize ||= []
        attributes.each do |key|
          @attributes_to_serialize << Attribute.new(key, options[:if], &block)
        end
      end

      alias attribute attributes
    end
  end
end
