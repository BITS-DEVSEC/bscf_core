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

      after_save :update_virtual_account_status, if: :saved_change_to_kyc_status?

      private

      def update_virtual_account_status
        return unless user&.virtual_account.present?

        if kyc_status == "approved"
          user.virtual_account.update(status: :active)
        elsif kyc_status == "rejected"
          user.virtual_account.update(status: :suspended)
        end
      end
    end
  end
end
