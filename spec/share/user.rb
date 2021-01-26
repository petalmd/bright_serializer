# frozen_string_literal: true

class User
  attr_reader :first_name, :last_name, :id
  attr_accessor :friends

  def initialize
    @first_name = Faker::Name.first_name
    @last_name = Faker::Name.last_name
    @id = Faker::Number.positive
  end

  alias read_attribute_for_serialization send
end
