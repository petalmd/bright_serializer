# frozen_string_literal: true

require 'bright_serializer/extensions/cache'

RSpec.describe BrightSerializer::Extensions::Cache do
	let(:instance) { described_class.new }

  describe 'using extension' do
    context 'When Rails is defined' do
      let!(:rails_class) do
        stub_const 'Rails', Class.new
      end

			let(:serializer_class) do
				Class.new do
					include BrightSerializer::Serializer
				end
			end

      it 'have Extension::Cache in ancestors' do
        expect(serializer_class.ancestors).include? described_class
			end
		end
	end

	describe '#serialize' do
		subject { instance.serialize(object) }

		it '' do
			
		end
	end
end
