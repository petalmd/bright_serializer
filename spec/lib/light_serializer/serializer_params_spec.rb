require_relative '../../share/user'

RSpec.describe LightSerializer::Serializer do
  let(:user) { User.new }

  describe 'params' do
    class UserWithParamsSerializer
      include LightSerializer::Serializer
      attributes :first_name, :last_name
      attribute :name do |object|
        "#{object.first_name} #{object.last_name}"
      end
      attribute :params do |_object, params|
        params
      end
    end
    let(:instance) { UserWithParamsSerializer.new(user, params: param) }

    let(:param) { Faker::Lorem.word }
    let(:result) do
      {
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}",
        params: param
      }
    end

    it 'serialize params' do
      expect(instance.to_hash).to eq(result)
    end
  end
end
