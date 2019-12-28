# frozen_string_literal: true

require 'spec_helper'
require 'oj'

RSpec.describe LightSerializer::Serializer do
  class User
		attr_reader :first_name, :last_name
		def initialize
			@first_name = Faker::Name.first_name
			@last_name = Faker::Name.last_name
		end
	end

  class UserSerializer
		include LightSerializer::Serializer
		attributes :first_name, :last_name
		attribute :name do |object|
			"#{object.first_name} #{object.last_name}"
		end
	end

  let(:user) { User.new }
  let(:instance) { UserSerializer.new(user) }

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

  describe 'condition' do
		class UserWithConditionSerializer
			include LightSerializer::Serializer
			attributes :first_name, :last_name
			attribute :name, if: proc { false } do |object|
				"#{object.first_name} #{object.last_name}"
			end
		end
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
