module Bscf
  module Core
    class VirtualAccount < ApplicationRecord
      PRODUCT_SCHEMES = %w[SAVINGS CURRENT LOAN].freeze
      VOUCHER_TYPES = %w[REGULAR SPECIAL TEMPORARY].freeze

      belongs_to :user

      validates :account_number, presence: true, uniqueness: true
      validates :cbs_account_number, presence: true, uniqueness: true
      validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :locked_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :interest_type, presence: true
      validates :branch_code, presence: true
      validates :product_scheme, presence: true, inclusion: { in: PRODUCT_SCHEMES }
      validates :voucher_type, presence: true, inclusion: { in: VOUCHER_TYPES }
      validates :status, presence: true
      validate :available_balance_sufficient
      has_many :sent_transactions, class_name: "Bscf::Core::VirtualAccountTransaction",
            foreign_key: "from_account_id", dependent: :restrict_with_error
      has_many :received_transactions, class_name: "Bscf::Core::VirtualAccountTransaction",
            foreign_key: "to_account_id", dependent: :restrict_with_error

      enum :interest_type, {
        simple: 0,
        compound: 1
      }

      enum :status, {
        pending: 0,
        active: 1,
        suspended: 2,
        closed: 3
      }

      before_validation :generate_account_number, on: :create

      scope :active_accounts, -> { where(active: true, status: :active) }
      scope :by_branch, ->(code) { where(branch_code: code) }
      scope :by_product, ->(scheme) { where(product_scheme: scheme) }

      def available_balance
        balance - locked_amount
      end

      def lock_amount!(amount)
        return false if amount <= 0
        return false if amount > available_balance

        transaction do
          self.locked_amount += amount
          save!
        end
      end

      def unlock_amount!(amount)
        return false if amount <= 0
        return false if amount > locked_amount

        transaction do
          self.locked_amount -= amount
          save!
        end
      end

      private

      def available_balance_sufficient
        return unless balance && locked_amount
        if locked_amount > balance
          errors.add(:locked_amount, "cannot exceed balance")
        end
      end

      def generate_account_number
        return if account_number.present?

        last_seq = self.class.maximum(:account_number).to_s[-6..-1].to_i
        seq = (last_seq + 1).to_s.rjust(6, "0")
        self.account_number = "#{branch_code}#{product_scheme}#{voucher_type}#{seq}"
      end

      def transfer_to!(to_account, amount)
        transaction = VirtualAccountTransaction.new(
          from_account: self,
          to_account: to_account,
          amount: amount,
          transaction_type: :transfer
        )

        transaction.process!
      end
    end
  end
end
