module Bscf::Core
  class LoanRepayment < ApplicationRecord
    belongs_to :loan, class_name: "Bscf::Core::Loan"
    belongs_to :repayment_transaction, class_name: "Bscf::Core::VirtualAccountTransaction"

    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :payment_date, presence: true
    validate :amount_cannot_exceed_unpaid_balance
    validate :loan_cannot_be_already_paid

    after_create :apply_repayment_to_loan

    private

    def apply_repayment_to_loan
      loan.with_lock do
        loan.unpaid_balance -= amount
        loan.unpaid_balance = 0 if loan.unpaid_balance.negative?

        if loan.unpaid_balance.zero?
          loan.status = "paid"
          loan.paid_at = payment_date
        end

        loan.save!
      end
    end

    def amount_cannot_exceed_unpaid_balance
      return if loan.blank? || amount.blank?

      if amount > loan.unpaid_balance
        errors.add(:amount, "cannot be greater than the loan's unpaid balance")
      end
    end

    def loan_cannot_be_already_paid
      return if loan.blank?

      if loan.paid?
        errors.add(:loan, "is already marked as paid")
      end
    end
  end
end
