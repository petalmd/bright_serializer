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
          "#{object.first_name} #{object.last_name} #{params[:suffix]}"
        end

        attribute :params_upcase do |object, params|
          upcase(object, params)
        end

        def upcase(object, params)
          "#{object.first_name} #{object.last_name} #{params[:suffix]}".upcase
        end
      end
    end

    let(:instance) { serializer_class.new(user, params: { suffix: param }) }

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

    context 'when not passing params' do
      # The anonymous serializer use params in a way that it take for granted that params is always a hash
      # and call params[:suffix], so if params is nil it will raise an error
      # This test ensure that when params is not passed it will be an empty hash and no error is raised.
      it 'passes an empty hash' do
        instance = serializer_class.new(user)
        expect(instance.to_hash).to eq(
          first_name: user.first_name,
          last_name: user.last_name,
          name: "#{user.first_name} #{user.last_name}",
          params: "#{user.first_name} #{user.last_name} ",
          params_upcase: "#{user.first_name} #{user.last_name} ".upcase
        )
      end
    end
  end
end
