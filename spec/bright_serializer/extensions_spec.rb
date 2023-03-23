# frozen_string_literal: true

require 'bright_serializer/extensions/instrumentation'

RSpec.describe BrightSerializer::Extensions do
  describe '::instrumentation_extension' do
    let(:class_to_add_extension) do
      Class.new do
        include BrightSerializer::Extensions
      end
    end

    context 'when ActiveSupport not defined' do
      before do
        hide_const 'ActiveSupport'
      end

      it 'does not prepend instrumentation' do
        expect(class_to_add_extension.ancestors).not_to include(BrightSerializer::Extensions::Instrumentation)
      end
    end

    context 'when ActiveSupport is defined' do
      before do
        stub_const 'ActiveSupport', true
      end

      it 'prepend Instrumentation' do
        expect(class_to_add_extension.ancestors).to include(BrightSerializer::Extensions::Instrumentation)
      end
    end
  end
end
