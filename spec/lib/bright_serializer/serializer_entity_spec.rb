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
      expect(subject).to eq(name: { type: :string })
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
        expect(subject).to eq(name: { type: :string }, id: { type: :undefined })
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
