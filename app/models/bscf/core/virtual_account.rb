module Bscf
  module Core
    class VirtualAccount < ApplicationRecord
      PRODUCT_SCHEMES = %w[SAVINGS CURRENT LOAN].freeze
      VOUCHER_TYPES = %w[REGULAR SPECIAL TEMPORARY].freeze

      belongs_to :user

      validates :account_number, presence: true, uniqueness: true
      validates :cbs_account_number, presence: true, uniqueness: true
      validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :interest_type, presence: true
      validates :branch_code, presence: true
      validates :product_scheme, presence: true, inclusion: { in: PRODUCT_SCHEMES }
      validates :voucher_type, presence: true, inclusion: { in: VOUCHER_TYPES }
      validates :status, presence: true

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

      private

      def generate_account_number
        return if account_number.present?

        last_seq = self.class.maximum(:account_number).to_s[-6..-1].to_i
        seq = (last_seq + 1).to_s.rjust(6, "0")
        self.account_number = "#{branch_code}#{product_scheme}#{voucher_type}#{seq}"
      end

      has_many :sent_transactions, class_name: "Bscf::Core::VirtualAccountTransaction",
               foreign_key: "from_account_id", dependent: :restrict_with_error
      has_many :received_transactions, class_name: "Bscf::Core::VirtualAccountTransaction",
               foreign_key: "to_account_id", dependent: :restrict_with_error
    end
  end
end
