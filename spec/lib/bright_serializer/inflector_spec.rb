# frozen_string_literal: true

RSpec.describe Inflector do
  describe '#constantize' do
    subject { described_class.constantize(camel_cased_word) }

    let(:camel_cased_word) { described_class.name }

    specify { is_expected.to eq described_class }
  end

  describe '#deep_transform_values_in_object' do
    subject { described_class.deep_transform_values_in_object(hash, &:capitalize) }

    let(:hash) { { users: [{ name: 'john' }] } }

    it 'transforms value' do
      expect(subject).to eq({ users: [{ name: 'John' }] })
    end
  end
end
