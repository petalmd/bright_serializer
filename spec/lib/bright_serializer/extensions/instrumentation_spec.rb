# frozen_string_literal: true

require 'bright_serializer/extensions/instrumentation'

RSpec.describe BrightSerializer::Extensions::Instrumentation do
  let(:instance) { described_class.new }

  describe 'using extension' do
    context 'when Rails is defined' do
      let(:rails_class) do
        stub_const 'ActiveSupport', Class.new
      end

      let(:serializer_class) do
        rails_class
        Class.new do
          include BrightSerializer::Serializer
        end
      end

      it 'have Extension::Instrumentation in ancestors' do
        expect(serializer_class.ancestors).to include described_class
      end
    end
  end
end
