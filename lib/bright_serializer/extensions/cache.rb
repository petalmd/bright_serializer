# frozen_string_literal: true

require 'active_support/notifications'

module BrightSerializer
  module Extensions
    module Cache

      def serialize(object)
        if @object.respond_to?(:cache_key) && self.class.cache_options
          Rails.cache.fetch("#{self.class.name}-#{@object.cache_key}", self.class.cache_options) do
            super
          end
        else
          super
        end
      end
    end
  end
end
