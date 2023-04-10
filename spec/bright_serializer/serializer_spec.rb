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

    context 'when element to serialize is nil' do
      let(:user) { nil }

      it 'serialize to hash should be nil' do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        instance.to_hash
        expect(ActiveSupport::Deprecation).to have_received(:warn).with(/will stop returning/)
      end
    end

    context 'when multiple element to serialize' do
      let(:users) { [User.new, User.new] }
      let(:user) { users }

      let(:result) do
        users.map do |user|
          {
            first_name: user.first_name,
            last_name: user.last_name,
            name: "#{user.first_name} #{user.last_name}",
            name_to_s: "User: #{user.first_name} #{user.last_name}",
            first: user.first_name
          }
        end
      end

      it 'serialize an array of hash' do
        expect(instance.to_hash).to eq(result)
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

      context 'when element to serialize is empty hash' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
          end
        end

        let(:user) { {} }

        let(:result) do
          {
            first_name: nil,
            last_name: nil
          }
        end

        it 'serialize to hash should be filled with nil' do
          expect(instance.to_hash).to eq(result)
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
        has_many :friends, serializer: 'FriendSerializer'
      end
    end
    let(:user) do
      user = User.new
      def user.best_friend
        friends.first
      end
      user.friends = [User.new, User.new]
      user
    end
    let(:expected_result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        friends: [
          { first_name: user.friends[0].first_name, last_name: user.friends[0].last_name },
          { first_name: user.friends[1].first_name, last_name: user.friends[1].last_name }
        ]
      }
    end

    let(:friend_serializer) do
      # FriendSerializer
      Class.new do
        include BrightSerializer::Serializer
        attributes :first_name, :last_name
      end
    end

    before do
      allow_any_instance_of(BrightSerializer::AttributeRelation).to( # rubocop:disable  RSpec/AnyInstance
        receive(:class_serializer).and_return(friend_serializer)
      )
    end

    it 'serializer has_many friends' do
      expect(serializer_class.new(user).serializable_hash).to eq expected_result
    end

    describe 'serialize nil from has_one' do
      let(:user) do
        user = User.new
        user.friends = nil
        user
      end

      let(:expected_result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          friends: nil
        }
      end

      it 'serializer has_many friends with nil' do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        serializer_class.new(user).serializable_hash
        expect(ActiveSupport::Deprecation).to have_received(:warn).with(/will stop returning/)
      end
    end

    describe 'aliases' do
      let(:expected_result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          best_friend: { first_name: user.friends[0].first_name, last_name: user.friends[0].last_name }
        }
      end

      context 'when belongs_to alias' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
            belongs_to :best_friend, serializer: 'FriendSerializer' do |object|
              object.friends.first
            end
          end
        end

        it 'serializer belongs_to best_friends' do
          expect(serializer_class.new(user).serializable_hash).to eq expected_result
        end
      end

      context 'when has_one alias' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
            has_one :best_friend, serializer: 'FriendSerializer' do |object|
              object.friends.first
            end
          end
        end

        it 'serializer belongs_to best_friends' do
          expect(serializer_class.new(user).serializable_hash).to eq expected_result
        end
      end
    end

    describe 'condition' do
      context 'when true' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
            has_many :friends, serializer: 'FriendSerializer', if: ->(_object, _params) { true }
          end
        end

        it 'serializer has_many friends' do
          expect(serializer_class.new(user).serializable_hash).to eq expected_result
        end
      end

      context 'when false' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
            has_many :friends, serializer: 'FriendSerializer', if: ->(_object, _params) { false }
          end
        end

        let(:expected_result) do
          {
            first_name: user.first_name,
            last_name: user.last_name
          }
        end

        it 'serializer has_many friends' do
          expect(serializer_class.new(user).serializable_hash).to eq expected_result
        end
      end
    end

    describe 'fields' do
      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          attributes :first_name, :last_name
          has_many :friends, serializer: 'FriendSerializer', fields: [:first_name]
        end
      end

      let(:expected_result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          friends: [
            { first_name: user.friends[0].first_name },
            { first_name: user.friends[1].first_name }
          ]
        }
      end

      it 'serializer has_many friends' do
        expect(serializer_class.new(user).serializable_hash).to eq expected_result
      end
    end

    describe 'params' do
      let(:expected_result) do
        {
          first_name: user.first_name,
          last_name: user.last_name,
          friends: [
            { first_name: user.friends[0].first_name, last_name: "Mr #{user.friends[0].last_name}" },
            { first_name: user.friends[1].first_name, last_name: "Mr #{user.friends[1].last_name}" }
          ]
        }
      end
      let(:friend_serializer) do
        # FriendSerializer
        Class.new do
          include BrightSerializer::Serializer
          attributes :first_name
          attribute :last_name do |object, params|
            "#{params[:prefix]} #{object.last_name}"
          end
        end
      end

      context 'when params comes from parent serializer instance' do
        it 'serializer has_many friends' do
          expect(serializer_class.new(user, params: { prefix: 'Mr' }).serializable_hash).to eq expected_result
        end
      end

      context 'when params comes from inside parent serializer' do
        let(:serializer_class) do
          Class.new do
            include BrightSerializer::Serializer
            attributes :first_name, :last_name
            has_many :friends, serializer: 'FriendSerializer', params: { prefix: 'Mr' }
          end
        end

        it 'serializer has_many friends' do
          expect(serializer_class.new(user).serializable_hash).to eq expected_result
        end
      end
    end
  end
end
