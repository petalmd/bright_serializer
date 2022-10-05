# frozen_string_literal: true

module BrightSerializer
  module Extensions
    module Instrumentation
      SERIALIZABLE_HASH_NOTIFICATION = 'render.bright_serializer.serializable_hash'
      SERIALIZED_JSON_NOTIFICATION = 'render.bright_serializer.serializable_json'

      def serializable_hash
        ActiveSupport::Notifications.instrument(SERIALIZABLE_HASH_NOTIFICATION, serializer: self.class.name) do
          super
        end
      end

      alias to_hash serializable_hash

      def serializable_json(*_args)
        ActiveSupport::Notifications.instrument(SERIALIZED_JSON_NOTIFICATION, serializer: self.class.name) do
          super
        end
      end

      alias to_json serializable_json
    end
  end
end
