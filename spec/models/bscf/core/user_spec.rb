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
        { email: :uniqueness }
      ]
      include_examples("model_shared_spec", :user, attributes)

      describe 'password validation' do
        it 'requires exactly 6 digits' do
          user = build(:user, password: 'abc123')
          expect(user).not_to be_valid
          expect(user.errors[:password]).to include('must be exactly 6 digits')

          user.password = '123456'
          expect(user).to be_valid
        end
      end
    end
  end
end
