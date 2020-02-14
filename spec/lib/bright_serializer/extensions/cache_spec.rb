# frozen_string_literal: true

require 'bright_serializer/extensions/cache'

RSpec.describe BrightSerializer::Extensions::Cache do
  let(:instance) { described_class.new }

  describe 'using extension' do
    context 'when Rails is defined' do
      let!(:rails_class) do
        stub_const 'Rails', Class.new
      end

      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          cache_options cache_length: 1, race_condition_ttl: 1
        end
      end

      let(:respond_to_cache_key) do
        Class.new do
          def cache_key; end
        end
      end

      it 'have Extension::Cache in ancestors' do
        expect(Rails).to receive_message_chain(:cache, :fetch)
        expect(serializer_class.ancestors).to include described_class
        serializer_class.new(respond_to_cache_key.new).serializable_hash
      end
    end
  end
end
