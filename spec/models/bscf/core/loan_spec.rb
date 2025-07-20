require 'rails_helper'

module Bscf::Core
  RSpec.describe Loan, type: :model do
      attributes = [
        { virtual_account: :belong_to },
        { disbursement_transaction: :belong_to },
        { principal_amount: [ :presence, :numericality ] },
        { interest_amount: [ :presence, :numericality ] },
        { unpaid_balance: [ :presence, :numericality ] },
        { status: :presence },
        { due_date: :presence }
      ]

      include_examples("model_shared_spec", :loan, attributes)

      describe "Loan payment validations" do
        context "when status is paid" do
          it "is valid if unpaid_balance is 0 and paid_at is present" do
            loan = build(:loan, status: :paid, unpaid_balance: 0, paid_at: Date.today)
            expect(loan).to be_valid
          end

          it "is invalid if unpaid_balance is greater than 0" do
            loan = build(:loan, status: :paid, unpaid_balance: 100, paid_at: Date.today)
            expect(loan).to_not be_valid
            expect(loan.errors[:status]).to include("can only be set to paid if unpaid balance is zero")
          end
        end

        context "when paid_at is present" do
          it "is invalid if status is not paid" do
            loan = build(:loan, status: :disbursed, unpaid_balance: 0, paid_at: Date.today)
            expect(loan).to_not be_valid
            expect(loan.errors[:paid_at]).to include("can only be set if loan is marked as paid")
          end

          it "is invalid if unpaid_balance is not 0" do
            loan = build(:loan, status: :paid, unpaid_balance: 50, paid_at: Date.today)
            expect(loan).to_not be_valid
            expect(loan.errors[:paid_at]).to include("can only be set if unpaid balance is zero")
          end
        end

        context "when paid_at is nil" do
          it "is valid regardless of unpaid_balance or status" do
            loan = build(:loan, status: :disbursed, unpaid_balance: 50, paid_at: nil)
            expect(loan).to be_valid
          end
        end
      end
  end
end
