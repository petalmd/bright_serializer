# frozen_string_literal: true

require_relative '../../share/user'

RSpec.describe BrightSerializer::Serializer do
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
  let(:instance) { serializer_class.new(user) }

  let(:result) do
    {
      first_name: user.first_name,
      last_name: user.last_name,
      name: "#{user.first_name} #{user.last_name}"
    }
  end

  describe 'serialize' do
    it 'serialize to hash' do
      expect(instance.to_hash).to eq(result)
    end

    it 'serialize to json' do
      expect(instance.to_json).to eq(Oj.dump(result))
    end
  end

  context 'when multiple element to serialize' do
    let(:users) { [User.new, User.new] }

    let(:result) do
      users.map do |user|
        {
          first_name: user.first_name,
          last_name: user.last_name,
          name: "#{user.first_name} #{user.last_name}"
        }
      end

      it 'serialize an array of hash' do
        expect(instance.to_hash).to eq(result)
      end
    end
  end
end
