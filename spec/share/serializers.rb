# frozen_string_literal: true

class FriendSerializer
  include BrightSerializer::Serializer

  attributes :first_name
  attribute :last_name, if: proc { |_object, params| params&.key?(:prefix) } do |object, params|
    "#{params[:prefix]}#{object.last_name}"
  end
end
