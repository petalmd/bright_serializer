# frozen_string_literal: true

require 'rspec'

RSpec.describe BrightSerializer::AttributeRelation do
  describe 'class_serializer' do
    let(:instance) { described_class.new(:key, serializer_argument, nil, nil, nil) }

    let(:serializer_class_stub) do
      Class.new do
        include BrightSerializer::Serializer
      end
    end

    before do
      allow(instance).to receive(:attribute_value)
    end

    context 'when a string' do
      let(:serializer_argument) { 'SomeClassSerializer' }

      it 'call constantize' do
        expect(Inflector).to receive(:constantize).with(serializer_argument).and_return(serializer_class_stub) # rubocop:disable RSpec/StubbedMock
        instance.serialize(nil, '', nil)
      end
    end

    context 'when constant' do
      let(:serializer_argument) do
        stub_const 'SomeClassSerializer', serializer_class_stub
        SomeClassSerializer
      end

      it 'doesnt call constantize' do
        expect(Inflector).not_to receive(:constantize)
        instance.serialize(nil, '', nil)
      end
    end
  end

  describe 'entity' do
    subject { instance.entity }

    let(:instance) { described_class.new(:key, 'SomeClassSerializer', nil, entity_options, nil) }

    context 'when type is object' do
      let(:entity_options) { { type: :object } }

      it 'add ref' do
        expect(BrightSerializer::Entity::Base).to receive(:new).with({ type: :object, ref: 'SomeClassSerializer' })
        instance
      end

      context 'when ref is already present' do
        let(:entity_options) { { type: :object, ref: 'DoesntOverwriteThisOne' } }

        it 'doesnt add ref' do
          expect(BrightSerializer::Entity::Base).to receive(:new).with({ type: :object, ref: 'DoesntOverwriteThisOne' })
          instance
        end
      end
    end

    context 'when type is array' do
      let(:entity_options) { { type: :array } }

      it 'add ref' do
        expect(BrightSerializer::Entity::Base).to(
          receive(:new).with({ type: :array, items: { ref: 'SomeClassSerializer' } })
        )
        instance
      end

      context 'when ref already set' do
        let(:entity_options) { { type: :array, items: { ref: 'DoesntOverwriteThisOne' } } }

        it 'doesnt add ref' do
          expect(BrightSerializer::Entity::Base).to(
            receive(:new).with({ type: :array, items: { ref: 'DoesntOverwriteThisOne' } })
          )
          instance
        end
      end
    end

    context 'when type is something else' do
      let(:entity_options) { { type: :string } }

      it 'doesnt add ref' do
        expect(BrightSerializer::Entity::Base).to receive(:new).with(entity_options)
        instance
      end
    end

    context 'when entity is nil' do
      let(:entity_options) { nil }

      it 'doesnt call Entity::Base.new ' do
        expect(BrightSerializer::Entity::Base).not_to receive(:new)
        instance
      end
    end
  end
end
