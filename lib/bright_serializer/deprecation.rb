# frozen_string_literal: true

require 'active_support/deprecation'

module BrightSerializer
  class Deprecation < ActiveSupport::Deprecation
    DEPRECATION_MESSAGE = 'BrightSerializer: Serializing `nil` will stop returning ' \
                          "a JSON with all attributes and null values.\n" \
                          "To use the new behaviour use the class level setting `serialize_nil_if_nil`.\n" \
                          'To keep the old behaviour using an empty hash may work: ' \
                          "`MySerializer.new(object || { }).to_json`.\n" \
                          'See: https://github.com/petalmd/bright_serializer/issues/103 ' \
                          "for more details about this change.\n"
    private_constant :DEPRECATION_MESSAGE

    def initialize
      super('0.7.0', 'BrightSerializer')
    end

    def self.warn(klass)
      super(DEPRECATION_MESSAGE + "Called from `#{klass}`.\n")
    end
  end
end
