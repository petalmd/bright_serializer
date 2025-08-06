# frozen_string_literal: true

require_relative '../share/user'

RSpec.describe BrightSerializer::Serializer do
  let(:user) { User.new }

  describe 'params' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
        attribute :params do |object, params|
          "#{object.first_name} #{object.last_name} #{params}"
        end

        attribute :params_upcase do |object, params|
          upcase(object, params)
        end

        def upcase(object, params)
          "#{object.first_name} #{object.last_name} #{params}".upcase
        end
      end
    end

    let(:instance) { serializer_class.new(user, params: param) }

    let(:param) { Faker::Lorem.word }
    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}",
        params: "#{user.first_name} #{user.last_name} #{param}",
        params_upcase: "#{user.first_name} #{user.last_name} #{param}".upcase
      }
    end

    it 'serialize params' do
      expect(instance.to_hash).to eq(result)
    end
  end
end
