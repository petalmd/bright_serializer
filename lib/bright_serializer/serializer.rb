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

      if defined? Rails
        require_relative 'extensions/cache'
        base.prepend Extensions::Cache
      end

      if defined? ActiveSupport
        require_relative 'extensions/instrumentation'
        base.prepend Extensions::Instrumentation
      end
    end

    def initialize(object, **options)
      @object = object
      @params = options.delete(:params)
      @fields = Set.new(options.delete(:fields))
    end

    def serialize(object)
      self.class.attributes_to_serialize.each_with_object({}) do |attribute, result|
        next if @fields.any? && !@fields.include?(attribute.key)
        next unless attribute.condition?(object, @params)

        result[attribute.transformed_key] = attribute.serialize(object, @params)
      end
    end

    def serializable_hash
      if @object.respond_to?(:size) && !@object.respond_to?(:each_pair)
        @object.map { |o| serialize o }
      else
        serialize(@object)
      end
    end

    alias to_hash serializable_hash

    def serializable_json(*_args)
      ::Oj.dump(to_hash, DEFAULT_OJ_OPTIONS)
    end

    alias to_json serializable_json

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

      def cache_options(cache_options)
        @cache_options = {
          cache_length: cache_options[:cache_length] || 5.minutes,
          race_condition_ttL: cache_options[:race_condition_ttl] || 5.seconds
        }
      end
    end
  end
end
# require 'rails'; require_relative 'lib/bright_serializer'; class Hello; include BrightSerializer::Serializer; end
