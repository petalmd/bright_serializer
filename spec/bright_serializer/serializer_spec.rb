# frozen_string_literal: true

require_relative '../share/user'
require_relative '../share/serializers'

RSpec.describe BrightSerializer::Serializer do
  describe '#serialize' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer
        attributes :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
        attribute :name_to_s do |object|
          add_mr(object)
        end
        attribute :first, &:first_name

        def add_mr(object)
          "User: #{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:user) { User.new }
    let(:instance) { serializer_class.new(user) }

    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}",
        name_to_s: "User: #{user.first_name} #{user.last_name}",
        first: user.first_name
      }
    end

    it 'serialize to hash' do
      expect(instance.to_hash).to eq(result)
    end

    it 'serialize to json' do
      expect(instance.to_json).to eq(result.to_json)
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

    context 'when embedded serializer' do
      let(:serializer_class) do
        small_serializer = Class.new do
          include BrightSerializer::Serializer
          attributes :names do |object|
            [object.first_name, object.last_name]
          end
        end

        Class.new do
          include BrightSerializer::Serializer
          attributes :first_name, :last_name
          attribute :name do |object|
            small_serializer.new(object)
          end
        end
      end

      let(:result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          name: { names: [user.first_name, user.last_name] }
        }
      end

      it { expect(instance.to_hash).to eq(result) }

      context 'when the object is an Hash with string keys' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
          end
        end

        let(:user_hash) do
          {
            'first_name' => user.first_name,
            'last_name' => user.last_name
          }
        end

        let(:result) do
          {
            first_name: user.first_name,
            last_name: user.last_name
          }
        end

        it 'serialize all 3 attributes' do
          expect(serializer_class.new(user_hash).to_hash).to eq(result)
        end
      end
    end
  end

  describe '.inherited' do
    let(:parent_class) do
      Class.new do
        include BrightSerializer::Serializer
        attributes :first_name
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        attribute :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    it 'return all 3 attributes' do
      expect(child_class.attributes_to_serialize.map(&:key)).to eq(%i[first_name last_name name])
    end

    context 'when serialize' do
      let(:result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          name: "#{user.first_name} #{user.last_name}"
        }
      end
      let(:user) { User.new }

      it 'serialize all 3 attributes' do
        expect(child_class.new(user).to_hash).to eq(result)
      end
    end

    describe 'transform_key' do
      let(:parent_class) do
        Class.new do
          include BrightSerializer::Serializer
          set_key_transform :camel_lower
          attributes :first_name
        end
      end

      let(:result) do
        {
          firstName: user.first_name,
          lastName: user.last_name,
          name: "#{user.first_name} #{user.last_name}"
        }
      end
      let(:user) { User.new }

      it 'serialize all 3 attributes' do
        expect(child_class.new(user).to_hash).to eq(result)
      end
    end
  end

  describe '#has_one' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer
        attributes :first_name, :last_name
        has_many :friends, class_name: 'FriendSerializer'
        has_one :best_friend, class_name: 'FriendSerializer'
        has_one :second_best_friend, class_name: 'FriendSerializer', if: proc { false }
        belongs_to :third_best_friend, class_name: 'FriendSerializer', params: { prefix: 'Mr ' }
      end
    end

    let(:user) do
      user = User.new
      def user.best_friend
        @best_friend ||= User.new
      end

      def user.third_best_friend
        @third_best_friend ||= User.new
      end
      user.friends = [User.new, User.new]
      user
    end

    let(:expected_result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        friends: [
          { first_name: user.friends[0].first_name },
          { first_name: user.friends[1].first_name }
        ],
        best_friend: { first_name: user.best_friend.first_name },
        third_best_friend: {
          first_name: user.third_best_friend.first_name,
          last_name: "Mr #{user.third_best_friend.last_name}"
        }
      }
    end

    it 'serializer has_many friends' do
      expect(serializer_class.new(user).serializable_hash).to eq expected_result
    end
  end
end
