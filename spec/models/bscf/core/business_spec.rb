require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Business, type: :model do
      attributes = [
        { business_name: [ :presence ] },
        { tin_number: [ :presence ] },
        { business_type: [ :presence ] },
        { verification_status: [ :presence ] },
        { user: :belong_to }
      ]

      include_examples("model_shared_spec", :business, attributes)

      describe 'validations' do
        describe 'tin_number uniqueness' do
          subject { build(:business) }
          it { should validate_uniqueness_of(:tin_number).case_insensitive }
        end
      end

      describe 'enums' do
        it { should define_enum_for(:business_type).with_values(retailer: 0, wholesaler: 1) }
        it { should define_enum_for(:verification_status).with_values(pending: 0, approved: 1, rejected: 2) }
      end

      describe 'associations' do
        it { should belong_to(:user).class_name('Bscf::Core::User') }
      end

      describe 'defaults' do
        let(:business) { build(:business) }

        it 'sets default business_type to retailer' do
          expect(business.business_type).to eq('retailer')
        end

        it 'sets default verification_status to pending' do
          expect(business.verification_status).to eq('pending')
        end
      end

      describe 'factory traits' do
        it 'creates wholesaler business' do
          business = create(:business, :wholesaler)
          expect(business).to be_wholesaler
        end

        it 'creates approved business' do
          business = create(:business, :approved)
          expect(business).to be_approved
          expect(business.verified_at).to be_present
        end

        it 'creates rejected business' do
          business = create(:business, :rejected)
          expect(business).to be_rejected
          expect(business.verified_at).to be_present
        end
      end
    end
  end
end
