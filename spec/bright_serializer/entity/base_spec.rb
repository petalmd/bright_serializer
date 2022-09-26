# frozen_string_literal: true

RSpec.describe BrightSerializer::Entity::Base do
  let(:instance) { described_class.new(type: :string) }
  let(:entity_class) do
    Class.new do
      include BrightSerializer::Serializer

      def self.entity_name
        'user'
      end
    end
  end

  before do
    allow(Inflector).to receive(:constantize) { entity_class }
  end

  describe '#to_h' do
    subject { instance.to_h }

    it 'return the definition' do
      expect(subject).to eq('type' => :string)
    end

    context 'when it is a array' do
      let(:instance) { described_class.new([type: :string]) }

      it 'return the definition' do
        expect(subject).to eq(['type' => :string])
      end
    end

    context 'when passing a callable object as value' do
      let(:instance) { described_class.new(type: :string, enum: -> { [1, 2] }) }

      it 'return the definition' do
        expect(subject).to eq('type' => :string, 'enum' => [1, 2])
      end
    end
  end

  describe '#parser_ref!' do
    subject { instance.to_h }

    let(:instance) { described_class.new(ref: 'SomeModule::User') }

    it 'modified @definition' do
      expect(subject).to eq('$ref' => '#/definitions/user')
    end

    context 'when deep ref' do
      let(:instance) do
        described_class.new(
          type: :array,
          items: { ref: 'SomeModule::User' }
        )
      end

      it 'modified @definition' do
        expect(subject).to(
          eq(
            'type' => :array,
            'items' => {
              '$ref' => '#/definitions/user'
            }
          )
        )
      end
    end
  end
end
