require 'rails_helper'

module Bscf
  module Core
    RSpec.describe UserProfile, type: :model do
      attributes = [
        { date_of_birth: :presence },
        { nationality: :presence },
        { gender: :presence },
        { user: :belong_to },
        { address: :belong_to }
      ]
      include_examples("model_shared_spec", :user_profile, attributes)

      it { is_expected.to belong_to(:verified_by).class_name('User').optional }
      
      describe "callbacks" do
        let(:user) { create(:user) }
        let(:address) { create(:address) }
        let(:user_profile) do
          create(:user_profile, user: user, address: address, kyc_status: :pending)
        end
        
        it "activates virtual account when KYC status is approved" do
          expect(user.virtual_account.status).to eq("pending")
          
          user_profile.update(kyc_status: :approved)
          user.reload
          
          expect(user.virtual_account.status).to eq("active")
        end
        
        it "suspends virtual account when KYC status is rejected" do
          expect(user.virtual_account.status).to eq("pending")
          
          user_profile.update(kyc_status: :rejected)
          user.reload
          
          expect(user.virtual_account.status).to eq("suspended")
        end
      end
    end
  end
end
