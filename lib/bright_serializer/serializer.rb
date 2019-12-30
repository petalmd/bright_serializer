# frozen_string_literal: true

require 'oj'
require 'set'
require_relative 'attribute'
require_relative 'inflector'

module BrightSerializer
  module Serializer
    SUPPORTED_TRANSFORMATION = %i[camel camel_lower dash underscore].freeze

    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(object, **options)
      @object = object
      @params = options[:params]
      @fields = Set.new(options[:fields])
      @options = options
    end

    def to_hash
      if @object.respond_to?(:each)
        @object.map { |o| serialize o }
      else
        serialize(@object)
      end
    end

    def serialize(object)
      self.class.attributes_to_serialize.each_with_object({}) do |attribute, result|
        next if @fields.any? && !@fields.include?(attribute.key)
        next unless attribute.condition?(object, @params)

        result[self.class.run_transform_key(attribute.key)] = attribute.serialize(object, @params)
      end
    end

    alias serialize_hash to_hash

    def to_json(*_args)
      ::Oj.dump(to_hash, mode: :compat, time_format: :ruby, use_to_json: true)
    end

    alias serialize_json to_json

    module ClassMethods
      attr_reader :attributes_to_serialize, :transform_method

      def attributes(*attributes, **options, &block)
        @attributes_to_serialize ||= []
        attributes.each do |key|
          @attributes_to_serialize << Attribute.new(key, options[:if], &block)
        end
      end

      alias attribute attributes

      def set_key_transform(transform_name) # rubocop:disable Naming/AccessorMethodName
        unless SUPPORTED_TRANSFORMATION.include?(transform_name)
          raise ArgumentError "Invalid transformation: #{SUPPORTED_TRANSFORMATION}"
        end

        @transform_method = transform_name
      end

      def run_transform_key(input)
        if transform_method
          Inflector.send(@transform_method, input.to_s).to_sym
        else
          input.to_sym
        end
      end
    end
  end
end
