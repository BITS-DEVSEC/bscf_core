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
        context 'when both latitude and longitude are present' do
          it 'returns an array with latitude and longitude symbols' do
            # Assuming you have a factory for Address or can build an instance
            # If using factories (e.g., FactoryBot), it would be something like:
            # address = build(:address, latitude: '10.0', longitude: '20.0')
            # For now, let's instantiate directly for clarity if no factory is set up for this example
            address = Address.new(latitude: '10.0', longitude: '20.0')
            expect(address.coordinates).to eq([ :latitude, :longitude ])
          end
        end

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
