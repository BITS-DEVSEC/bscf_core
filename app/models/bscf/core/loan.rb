module Bscf::Core
  class Loan < ApplicationRecord
    belongs_to :virtual_account, class_name: "Bscf::Core::VirtualAccount"
    belongs_to :disbursement_transaction, class_name: "Bscf::Core::VirtualAccountTransaction"

    enum :status, { disbursed: 0, late: 1, paid: 2 }

    validates :principal_amount, :interest_amount, :unpaid_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :status, :due_date, presence: true
    validates :status, inclusion: { in: statuses.keys }

    validate :paid_at_requires_zero_balance_and_paid_status
    validate :paid_status_requires_zero_balance

    def paid_at_requires_zero_balance_and_paid_status
      if paid_at.present?
        errors.add(:paid_at, "can only be set if loan is marked as paid") if status != "paid"
        errors.add(:paid_at, "can only be set if unpaid balance is zero") if unpaid_balance.to_f > 0
      end
    end

    def paid_status_requires_zero_balance
      if status == "paid" && unpaid_balance.to_f > 0
        errors.add(:status, "can only be set to paid if unpaid balance is zero")
      end
    end
  end
end
