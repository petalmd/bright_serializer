require_relative './lib/bright_serializer'

class User
  attr_accessor :friends, :id, :first_name, :last_name
  def initialize(id, first_name, last_name)
    @id = id
    @first_name = first_name
    @last_name = last_name
  end
end

class UserSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name

  has_many :friends, serializer: 'UserSerializer', if: ->(object, _) { object.friends }
end


list = 100.times.map { |i| User.new(i, "first_name_#{i}", "last_name_#{i}") }
list.each do |user|
  user.friends = list.sample(10).map { |u| nu = u.dup; nu.friends = nil; nu }
end


require 'ruby-prof'
# ---
profile = RubyProf.profile do
  UserSerializer.new(list).to_hash
end

File.open "./profile-stack.html", 'w+' do |file|
  RubyProf::CallStackPrinter.new(profile).print(file)
end
`open "./profile-stack.html"`




