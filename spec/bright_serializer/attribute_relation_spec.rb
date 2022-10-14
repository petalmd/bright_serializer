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
        expect(Inflector).to receive(:constantize).with(serializer_argument).and_return(serializer_class_stub)
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
end
