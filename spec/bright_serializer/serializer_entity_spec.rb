# frozen_string_literal: true

RSpec.describe BrightSerializer::Serializer do
  describe '.entity' do
    subject { serializer_class.entity }

    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer
        attribute :name, entity: { type: :string }
      end
    end

    it 'return name with his entity' do
      expect(subject).to eq(name: { 'type' => :string })
    end

    context 'when one is undefined' do
      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          attribute :name, entity: { type: :string }
          attribute :id
        end
      end

      it 'return name with his entity' do
        expect(subject).to eq(id: { type: :undefined }, name: { 'type' => :string })
      end
    end

    context 'when entity has a frozen array' do
      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          attribute :name, entity: { type: :string, enum: %w[a b c].freeze }
        end
      end

      it 'returns name with his entity' do
        expect(subject).to eq(name: { 'type' => :string, 'enum' => %w[a b c].freeze })
      end
    end

    context 'when entity has snake_case keys' do
      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          attribute :name, entity: { type: :string, my_param: 'abc' }
        end
      end

      it 'transforms keys to camel case' do
        expect(subject).to eq(name: { 'type' => :string, 'myParam' => 'abc' })
      end
    end
  end

  describe '.entity_name' do
    subject { serializer_class.entity_name }

    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer
      end
    end

    it 'return the class name downcase' do
      allow(serializer_class).to receive(:name).and_return('BrightSerializer::Serializer::User')
      expect(subject).to eq('user')
    end
  end
end
