# frozen_string_literal: true

require_relative '../../share/user'
require 'benchmark'
require 'active_model_serializers'
require 'active_support/core_ext/object/deep_dup'
require 'fast_jsonapi'

RSpec.describe BrightSerializer do
  let(:user) { User.new }

  describe 'AMS' do
    let!(:ams_serializer) do
      class AMSSerializer < ActiveModel::Serializer
        attributes :id, :first_name, :last_name, :name

        def name
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let(:bright_serializer) do
      Class.new do
        include BrightSerializer::Serializer
        attributes :id, :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    let!(:fast_jsonapi) do
      class FastSerializer
        include FastJsonapi::ObjectSerializer
        attributes :id, :first_name, :last_name
        attribute :name do |object|
          "#{object.first_name} #{object.last_name}"
        end
      end
    end

    it 'is faster' do
      [10, 50, 250, 1000].each do |times|
        puts times

        users = Array.new(times).map { User.new }
        ams = ActiveModel::Serializer::CollectionSerializer.new(users, serializer: AMSSerializer).to_json
        bright = bright_serializer.new(users).to_json
        Benchmark.bm(20) do |x|
          x.report('AMS') do
            users = Array.new(times).map { User.new }
            ActiveModel::Serializer::CollectionSerializer.new(users, serializer: AMSSerializer).to_json
          end
          x.report('FastJSONAPI') do
            users = Array.new(times).map { User.new }
            FastSerializer.new(users).to_json
          end
          x.report('BrightSerializer') do
            users = Array.new(times).map { User.new }
            bright_serializer.new(users).to_json
          end
        end
        expect(bright).to eq(ams)
      end
    end

    it 'is faster ips' do
      require 'benchmark/ips'
      users = Array.new(1000).map { User.new }

      Benchmark.ips do |x|
        x.report('AMS') do
          ActiveModel::Serializer::CollectionSerializer.new(users, serializer: AMSSerializer).to_json
        end
        x.report('FAST') do
          FastSerializer.new(users).to_json
        end
        x.report('Bright') do
          bright_serializer.new(users).to_json
        end
        x.compare!
      end
    end
  end
end
