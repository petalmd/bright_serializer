# frozen_string_literal: true

class User
  attr_reader :first_name, :last_name
  def initialize
    @first_name = Faker::Name.first_name
    @last_name = Faker::Name.last_name
  end
end
