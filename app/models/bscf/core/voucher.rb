module Bscf
  module Core
    class Voucher < ApplicationRecord
      belongs_to :issued_by, class_name: "Bscf::Core::User"

      validates :full_name, presence: true
      validates :phone_number, presence: true
      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :code, presence: true, uniqueness: true
      validate :issuer_has_sufficient_balance, on: :create

      enum :status, {
        pending: 0,
        active: 1,
        redeemed: 2,
        expired: 3,
        returned: 4,
        cancelled: 5
      }

      before_validation :generate_code, on: :create
      before_create :set_default_expiry
      after_create :lock_issuer_amount
      after_commit :unlock_issuer_amount, on: [ :update ], if: :should_unlock_amount?

      def redeem!(to_account)
        return false unless active?
        return false if expired? || returned? || cancelled?

        from_account = issued_by.virtual_account
        success = false

        ActiveRecord::Base.transaction do
          transaction = VirtualAccountTransaction.new(
            from_account: from_account,
            to_account: to_account,
            amount: amount,
            transaction_type: :transfer
          )

          unless transaction.process!
            errors.add(:base, "Voucher redemption failed due to transaction processing error.")
            raise ActiveRecord::Rollback
          end

          unless from_account.unlock_amount!(amount)
            errors.add(:base, "Failed to unlock amount from issuer after successful transfer.")
            raise ActiveRecord::Rollback
          end

          update!(status: :redeemed, redeemed_at: Time.current)
          success = true
        end

        success
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, "Voucher redemption failed: #{e.message}")
        false
      rescue ActiveRecord::Rollback
        false
      end

      def return!
        return false unless can_return?
        update!(status: :returned, returned_at: Time.current)
        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      def cancel!
        return false unless can_cancel?
        update!(status: :cancelled, returned_at: Time.current)
        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      def can_return?
        !redeemed? && !returned? && !cancelled? && !expired?
      end

      def can_cancel?
        (pending? || active?) && !expired? && !returned? && !redeemed?
      end

      private

      def generate_code
        self.code ||= SecureRandom.hex(8).upcase
      end

      def set_default_expiry
        self.expires_at ||= 30.days.from_now
      end

      def lock_issuer_amount
        issuer_account = issued_by.virtual_account
        unless issuer_account.available_balance >= amount
          errors.add(:amount, "exceeds available balance")
          return false
        end

        if issuer_account.lock_amount!(amount)
          update!(status: :active)
          true
        else
          errors.add(:amount, "could not be locked")
          false
        end
      end

      def unlock_issuer_amount
        issued_by.virtual_account.unlock_amount!(amount) if amount_should_be_unlocked?
      end

      def should_unlock_amount?
        (returned? || cancelled?) && status_previously_changed?
      end

      def amount_should_be_unlocked?
        returned? || cancelled?
      end

      def issuer_has_sufficient_balance
        return unless amount && issued_by&.virtual_account
        unless issued_by.virtual_account.available_balance >= amount
          errors.add(:amount, "exceeds available balance")
          throw :abort
        end
      end
    end
  end
end
