# frozen_string_literal: true

module BrightSerializer
  module Extensions
    module Cache
      def serialize(object)
        if @object.respond_to?(:cache_key) && self.class.cache_option_attributes
          Rails.cache.fetch("#{self.class.name}-#{@object.cache_key}", **self.class.cache_option_attributes) do
            super
          end
        else
          super
        end
      end
    end
  end
end
