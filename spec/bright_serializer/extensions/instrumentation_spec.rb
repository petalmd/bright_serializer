# frozen_string_literal: true

require 'bright_serializer/extensions/instrumentation'
require 'active_support/notifications'

RSpec.describe BrightSerializer::Extensions::Instrumentation do
  # Re-trigger the included hook since `BrightSerializer::Serializer` is
  # loaded before the `require 'active_support/notifications'` above.
  before do
    BrightSerializer::Extensions.included(BrightSerializer::Serializer)
    allow(ActiveSupport::Notifications).to receive(:instrument)
  end

  let(:serializer_class) do
    Class.new do
      include BrightSerializer::Serializer
      attributes :id, :name

      def self.name
        'TestSerializer'
      end
    end
  end

  describe '#serializable_hash' do
    it 'call instrument' do
      serializer_class.new({}).serializable_hash
      expect(ActiveSupport::Notifications).to(
        received(:instrument)
          .with('render.bright_serializer.serializable_hash', serializer: serializer_class.name)
      )
    end

    it 'call instrument with to_hash alias' do
      serializer_class.new({}).to_hash
      expect(ActiveSupport::Notifications).to(
        received(:instrument)
          .with('render.bright_serializer.serializable_hash', serializer: serializer_class.name)
      )
    end
  end

  describe '#serializable_json' do
    it 'call instrument' do
      serializer_class.new({}).serializable_json
      expect(ActiveSupport::Notifications).to(
        received(:instrument)
          .with('render.bright_serializer.serializable_json', serializer: serializer_class.name)
      )
    end

    it 'call instrument with to_json alias' do
      serializer_class.new({}).to_json
      expect(ActiveSupport::Notifications).to(
        received(:instrument)
          .with('render.bright_serializer.serializable_json', serializer: serializer_class.name)
      )
    end
  end
end
