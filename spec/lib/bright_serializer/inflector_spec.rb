# frozen_string_literal: true

RSpec.describe Inflector do
  describe '#constantize' do
    subject { described_class.constantize(camel_cased_word) }

    let(:camel_cased_word) { described_class.name }

    specify { is_expected.to eq described_class }
  end
end
