# frozen_string_literal: true

require 'oj'
require 'set'
require_relative 'attribute'
require_relative 'inflector'

module BrightSerializer
  module Serializer
    SUPPORTED_TRANSFORMATION = %i[camel camel_lower dash underscore].freeze
    DEFAULT_OJ_OPTIONS = { mode: :compat, time_format: :ruby, use_to_json: true }.freeze

    def self.included(base)
      base.extend ClassMethods
      base.instance_variable_set(:@attributes_to_serialize, [])
    end

    def initialize(object, **options)
      @object = object
      @params = options.delete(:params)
      @fields = Set.new(options.delete(:fields))
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

        result[attribute.transformed_key] = attribute.serialize(object, @params)
      end
    end

    alias serialize_hash to_hash

    def to_json(*_args)
      ::Oj.dump(to_hash, DEFAULT_OJ_OPTIONS)
    end

    alias serialize_json to_json

    module ClassMethods
      attr_reader :attributes_to_serialize, :transform_method

      def attributes(*attributes, **options, &block)
        attributes.each do |key|
          attribute = Attribute.new(key, options[:if], &block)
          attribute.transformed_key = run_transform_key(key)
          @attributes_to_serialize << attribute
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
