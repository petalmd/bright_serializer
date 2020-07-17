# frozen_string_literal: true

module BrightSerializer
  module Entity
    class Parser
      attr_reader :model
      attr_reader :endpoint

      def initialize(model, endpoint)
        @model = model
        @endpoint = endpoint
      end

      def call
        @model.entity
      end
    end
  end
end
