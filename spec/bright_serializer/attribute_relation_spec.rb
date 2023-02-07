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
        allow(Inflector).to receive(:constantize).and_return(serializer_class_stub)
        instance.serialize(nil, '', nil)
        expect(Inflector).to have_received(:constantize).with(serializer_argument)
      end
    end

    context 'when constant' do
      let(:serializer_argument) do
        stub_const 'SomeClassSerializer', serializer_class_stub
        SomeClassSerializer
      end

      it 'doesnt call constantize' do
        allow(Inflector).to receive(:constantize)
        instance.serialize(nil, '', nil)
        expect(Inflector).not_to have_received(:constantize)
      end
    end
  end

  describe 'entity' do
    subject { instance.entity }

    before do
      allow(BrightSerializer::Entity::Base).to receive(:new)
    end

    let(:instance) { described_class.new(:key, 'SomeClassSerializer', nil, entity_options, nil) }

    context 'when type is object' do
      let(:entity_options) { { type: :object } }

      it 'add ref' do
        instance
        expect(BrightSerializer::Entity::Base).to(
          have_received(:new).with({ type: :object, ref: 'SomeClassSerializer' })
        )
      end

      context 'when ref is already present' do
        let(:entity_options) { { type: :object, ref: 'DoesntOverwriteThisOne' } }

        it 'doesnt add ref' do
          instance
          expect(BrightSerializer::Entity::Base).to(
            have_received(:new).with({ type: :object, ref: 'DoesntOverwriteThisOne' })
          )
        end
      end
    end

    context 'when type is array' do
      let(:entity_options) { { type: :array } }

      it 'add ref' do
        instance
        expect(BrightSerializer::Entity::Base).to(
          have_received(:new).with({ type: :array, items: { ref: 'SomeClassSerializer' } })
        )
      end

      context 'when ref already set' do
        let(:entity_options) { { type: :array, items: { ref: 'DoesntOverwriteThisOne' } } }

        it 'doesnt add ref' do
          instance
          expect(BrightSerializer::Entity::Base).to(
            have_received(:new).with({ type: :array, items: { ref: 'DoesntOverwriteThisOne' } })
          )
        end
      end
    end

    context 'when type is something else' do
      let(:entity_options) { { type: :string } }

      it 'doesnt add ref' do
        instance
        expect(BrightSerializer::Entity::Base).to have_received(:new).with(entity_options)
      end
    end

    context 'when entity is nil' do
      let(:entity_options) { nil }

      it 'doesnt call Entity::Base.new' do
        instance
        expect(BrightSerializer::Entity::Base).not_to have_received(:new)
      end
    end
  end
end
