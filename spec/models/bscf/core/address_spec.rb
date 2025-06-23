require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Address, type: :model do
      attributes = [
        { user_profiles: :have_many }
        # Add other relevant attributes and validations if you update the shared examples
      ]
      include_examples("model_shared_spec", :address, attributes)

      describe '#coordinates' do
        context 'when latitude is present but longitude is nil' do
          it 'returns nil' do
            address = Address.new(latitude: '10.0', longitude: nil)
            expect(address.coordinates).to be_nil
          end
        end

        context 'when longitude is present but latitude is nil' do
          it 'returns nil' do
            address = Address.new(latitude: nil, longitude: '20.0')
            expect(address.coordinates).to be_nil
          end
        end

        context 'when both latitude and longitude are nil' do
          it 'returns nil' do
            address = Address.new(latitude: nil, longitude: nil)
            expect(address.coordinates).to be_nil
          end
        end

        context 'when latitude is an empty string' do
          it 'returns nil' do
            address = Address.new(latitude: '', longitude: '20.0')
            expect(address.coordinates).to be_nil
          end
        end

        context 'when longitude is an empty string' do
          it 'returns nil' do
            address = Address.new(latitude: '10.0', longitude: '')
            expect(address.coordinates).to be_nil
          end
        end

        context 'when both latitude and longitude are empty strings' do
          it 'returns nil' do
            address = Address.new(latitude: '', longitude: '')
            expect(address.coordinates).to be_nil
          end
        end
      end
    end
  end
end
