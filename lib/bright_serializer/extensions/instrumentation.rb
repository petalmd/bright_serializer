# frozen_string_literal: true

require 'active_support/notifications'

module BrightSerializer
  module Extensions
    module Instrumentation
      SERIALIZABLE_HASH_NOTIFICATION = 'render.bright_serializer.serializable_hash'
      SERIALIZED_JSON_NOTIFICATION = 'render.bright_serializer.serialized_json'

      def to_hash
        ActiveSupport::Notifications.instrument(SERIALIZABLE_HASH_NOTIFICATION, name: self.class.name) do
          super
        end
      end

      alias serialize_hash to_hash

      def to_json(*_args)
        ActiveSupport::Notifications.instrument(SERIALIZED_JSON_NOTIFICATION, name: self.class.name) do
          super
        end
      end

      alias serialize_json to_json
    end
  end
end
