# frozen_string_literal: true

require_relative '../share/user'

RSpec.describe BrightSerializer::Serializer do
  describe 'condition' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer

        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:user) { User.new }
    let(:instance) { serializer_class.new(user, fields: %i[first_name name]) }

    let(:result) do
      {
        first_name: user.first_name,
        name: "#{user.first_name} #{user.last_name}"
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end
  end
end
