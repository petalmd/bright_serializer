# frozen_string_literal: true

RSpec.describe Inflector do
  describe '#deep_transform_values_in_object' do
    subject { described_class.deep_transform_values_in_object(obj, &:capitalize) }

    context 'when hash' do
      let(:obj) { { users: [name: 'john'] } }

      it { is_expected.to match(users: [name: 'John']) }
    end

    context 'when Array' do
      let(:obj) { [users: [name: 'john']] }

      it { is_expected.to match([users: [name: 'John']]) }
    end

    context 'when Object' do
      let(:obj) { :object }

      it { is_expected.to eq(obj) }
    end
  end

  describe '#deep_transform_keys_in_object' do
    subject { described_class.deep_transform_keys_in_object(obj, &:capitalize) }

    context 'when Hash' do
      let(:obj) { { users: [name: 'john'] } }

      it { is_expected.to match(Users: [Name: 'john']) }
    end

    context 'when Array' do
      let(:obj) { [users: [name: 'john']] }

      it { is_expected.to match([Users: [Name: 'john']]) }
    end

    context 'when Object' do
      let(:obj) { :object }

      it { is_expected.to eq(obj) }
    end
  end
end
