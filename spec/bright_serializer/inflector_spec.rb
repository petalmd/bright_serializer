# frozen_string_literal: true

RSpec.describe Inflector do
  describe '#deep_transform_values_in_object' do
    subject { described_class.deep_transform_values_in_object(hash, &:capitalize) }

    let(:hash) { { users: [{ name: 'john' }] } }

    it 'transforms value' do
      expect(subject).to eq({ users: [{ name: 'John' }] })
    end
  end

  describe '#deep_transform_keys_in_object' do
    subject { described_class.deep_transform_keys_in_object(hash, &:capitalize) }

    let(:hash) { { users: [{ name: 'john' }] } }

    it 'transforms key' do
      expect(subject).to eq({ Users: [{ Name: 'john' }] })
    end
  end
end
