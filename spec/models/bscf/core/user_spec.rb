require 'rails_helper'

module Bscf
  module Core
    RSpec.describe User, type: :model do
      attributes = [
        { first_name: :presence },
        { middle_name: :presence },
        { last_name: :presence },
        { password: :presence },
        { phone_number: :presence },
        { business: :have_one },
        { vehicle: :have_one },
        { email: :uniqueness }
      ]
      
      include_examples("model_shared_spec", :user, attributes)
      
      # Add this test for the automatic virtual account creation
      describe "callbacks" do
        it "creates a virtual account after user creation" do
          user = create(:user)
          expect(user.virtual_account).to be_present
          expect(user.virtual_account.branch_code).to eq("VA001")
          expect(user.virtual_account.product_scheme).to eq("SAVINGS")
          expect(user.virtual_account.voucher_type).to eq("REGULAR")
          expect(user.virtual_account.status).to eq("pending")
        end
      end
    end
  end
end
