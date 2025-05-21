module Bscf
  module Core
    class UserProfile < ApplicationRecord
      belongs_to :user
      belongs_to :address
      belongs_to :verified_by, class_name: "User", optional: true

      validates :date_of_birth, presence: true
      validates :nationality, presence: true
      validates :gender, presence: true

      enum :gender, {
        male: 0,
        female: 1
      }

      enum :kyc_status, {
        pending: 0,
        approved: 1,
        rejected: 2
      }
    end
  end
end
