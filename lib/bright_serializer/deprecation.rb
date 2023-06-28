# frozen_string_literal: true

require 'active_support/deprecation'

module BrightSerializer
  class Deprecation
    DEPRECATION_INSTANCE = ActiveSupport::Deprecation.new('0.7.0', 'BrightSerializer')
    private_constant :DEPRECATION_INSTANCE
    DEPRECATION_MESSAGE = 'BrightSerializer: Serializing `nil` will stop returning ' \
                          "a JSON with all attributes and null values.\n" \
                          "To use the new behaviour use the class level setting `serialize_nil_if_nil`.\n" \
                          'To keep the old behaviour using an empty hash may work: ' \
                          "`MySerializer.new(object || { }).to_json`.\n" \
                          'See: https://github.com/petalmd/bright_serializer/issues/103 ' \
                          "for more details about this change.\n"
    private_constant :DEPRECATION_MESSAGE

    def self.warn
      DEPRECATION_INSTANCE.warn(DEPRECATION_MESSAGE)
    end
  end
end
