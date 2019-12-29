require_relative '../../share/user'

RSpec.describe LightSerializer::Serializer do
  describe 'condition' do
    class UserWithConditionSerializer
      include LightSerializer::Serializer
      attributes :first_name, :last_name
      attribute :name, if: proc { false } do |object|
        "#{object.first_name} #{object.last_name}"
      end
    end

    let(:user) { User.new }
    let(:instance) { UserWithConditionSerializer.new(user) }

    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
      }
    end

    it 'serialize without name' do
      expect(instance.to_hash).to eq(result)
    end

    context 'condition with params' do
      class UserWithParamsConditionSerializer
        include LightSerializer::Serializer
        attributes :first_name, :last_name
        attribute :name, if: proc { |_object, params| params != 0 } do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
      let(:instance) { UserWithParamsConditionSerializer.new(user, params: 0) }

      it 'serialize without name' do
        expect(instance.to_hash).to eq(result)
      end
    end
  end
end
