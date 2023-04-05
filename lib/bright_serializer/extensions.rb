# frozen_string_literal: true

module BrightSerializer
  module Extensions
    def self.included(base)
      instrumentation_extension(base)
    end

    def self.instrumentation_extension(base)
      return unless defined? ActiveSupport::Notifications

      require_relative 'extensions/instrumentation'
      base.prepend Instrumentation
    end
  end
end
