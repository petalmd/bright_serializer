# frozen_string_literal: true

require_relative '../../share/user'

RSpec.describe BrightSerializer::Serializer do
  let(:user) { User.new }

  describe 'camel_lower' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        set_key_transform :camel_lower
        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:instance) { serializer_class.new(user) }

    let(:result) do
      {
        firstName: user.first_name,
        lastName: user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize with camel_lower key' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'camel' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        set_key_transform :camel
        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:instance) { serializer_class.new(user) }

    let(:result) do
      {
        FirstName: user.first_name,
        LastName: user.last_name,
        Name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize with camel key' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'dash' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        set_key_transform :dash
        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:instance) { serializer_class.new(user) }

    let(:result) do
      {
        'first-name': user.first_name,
        'last-name': user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize with dash key' do
      expect(instance.to_hash).to eq(result)
    end
  end

  describe 'underscore' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        set_key_transform :underscore
        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:instance) { serializer_class.new(user) }

    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize with underscore key' do
      expect(instance.to_hash).to eq(result)
    end
  end
end
