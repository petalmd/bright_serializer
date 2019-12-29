require_relative '../../share/user'

RSpec.describe LightSerializer::Serializer do
  let(:user) { User.new }

  describe 'camel_lower' do
    class UserCamelLowerSerializer
      include LightSerializer::Serializer

      set_key_transform :camel_lower
      attributes :first_name, :last_name
      attribute :name do |object|
        "#{object.first_name} #{object.last_name}"
      end
    end

    let(:instance) { UserCamelLowerSerializer.new(user) }

    let(:result) do
      {
        firstName: user.first_name,
        lastName: user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'camel' do
    class UserCamelSerializer
      include LightSerializer::Serializer

      set_key_transform :camel
      attributes :first_name, :last_name
      attribute :name do |object|
        "#{object.first_name} #{object.last_name}"
      end
    end

    let(:instance) { UserCamelSerializer.new(user) }

    let(:result) do
      {
        FirstName: user.first_name,
        LastName: user.last_name,
        Name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'dash' do
    class UserCamelSerializer
      include LightSerializer::Serializer

      set_key_transform :camel
      attributes :first_name, :last_name
      attribute :name do |object|
        "#{object.first_name} #{object.last_name}"
      end
    end

    let(:instance) { UserCamelSerializer.new(user) }

    let(:result) do
      {
        FirstName: user.first_name,
        LastName: user.last_name,
        Name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'underscore' do
    class UserUnderscoreSerializer
      include LightSerializer::Serializer

      set_key_transform :underscore
      attributes :first_name, :last_name
      attribute :name do |object|
        "#{object.first_name} #{object.last_name}"
      end
    end

    let(:instance) { UserUnderscoreSerializer.new(user) }

    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end
  end
end
