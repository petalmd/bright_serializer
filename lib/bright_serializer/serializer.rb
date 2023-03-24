# frozen_string_literal: true

require 'oj'
require_relative 'attribute'
require_relative 'attribute_relation'
require_relative 'inflector'
require_relative 'entity/base'
require_relative 'extensions'

module BrightSerializer
  module Serializer
    include Extensions

    SUPPORTED_TRANSFORMATION = %i[camel camel_lower dash underscore].freeze
    DEFAULT_OJ_OPTIONS = { mode: :compat, time_format: :ruby, use_to_json: true }.freeze

    def self.included(base)
      super
      base.extend ClassMethods
      base.instance_variable_set(:@attributes_to_serialize, [])
    end

    def initialize(object, **options)
      @object = object
      @params = options.delete(:params)
      @fields = options.delete(:fields)
    end

    def serialize(object, attributes_to_serialize)
      return nil if @object.nil?

      attributes_to_serialize.each_with_object({}) do |attribute, result|
        next unless attribute.condition?(object, @params)

        result[attribute.transformed_key] = attribute.serialize(self, object, @params)
      end
    end

    def serializable_hash
      if @object.respond_to?(:each) && !@object.respond_to?(:each_pair)
        @object.map { |o| serialize(o, instance_attributes_to_serialize) }
      else
        serialize(@object, instance_attributes_to_serialize)
      end
    end

    alias to_hash serializable_hash

    def serializable_json(*_args)
      ::Oj.dump(to_hash, DEFAULT_OJ_OPTIONS)
    end

    alias to_json serializable_json

    module ClassMethods
      attr_reader :attributes_to_serialize, :transform_method

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@attributes_to_serialize, []) unless subclass.attributes_to_serialize
        subclass.attributes_to_serialize.concat(@attributes_to_serialize)
        subclass.instance_variable_set(:@transform_method, @transform_method) unless subclass.transform_method
      end

      def attributes(*args, &block)
        options = args.extract_options!
        args.each do |key|
          attribute = Attribute.new(key, options[:if], options[:entity], &block)
          attribute.transformed_key = run_transform_key(key)
          @attributes_to_serialize << attribute
        end
      end

      alias attribute attributes

      def has_one(key, serializer:, **options, &block) # rubocop:disable Naming/PredicateName
        attribute = AttributeRelation.new(
          key, serializer, options.delete(:if), options.delete(:entity), options, &block
        )
        attribute.transformed_key = run_transform_key(key)
        @attributes_to_serialize << attribute
      end

      alias has_many has_one
      alias belongs_to has_one

      def set_key_transform(transform_name) # rubocop:disable Naming/AccessorMethodName
        unless SUPPORTED_TRANSFORMATION.include?(transform_name)
          raise ArgumentError, "Invalid transformation: #{SUPPORTED_TRANSFORMATION}"
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

      def entity
        {}.tap do |result|
          @attributes_to_serialize.each do |attribute|
            entity_value = attribute.entity&.to_h ||
                           BrightSerializer::Entity::Base::DEFAULT_DEFINITION
            result.merge!(attribute.transformed_key => entity_value)
          end
        end
      end

      def entity_name
        name.split('::').last.downcase
      end
    end

    private

    def instance_attributes_to_serialize
      @instance_attributes_to_serialize ||=
        if @fields.nil?
          self.class.attributes_to_serialize
        else
          self.class.attributes_to_serialize.select do |field|
            @fields.include?(field.key)
          end
        end
    end
  end
end
