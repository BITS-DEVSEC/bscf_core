require 'rails_helper'

module Bscf::Core
  RSpec.describe LoanRepayment, type: :model do
    attributes = [
      { loan: :belong_to },
      { repayment_transaction: :belong_to },
      { amount: [ :presence, :numericality ] },
      { payment_date: :presence }
    ]

    include_examples("model_shared_spec", :loan_repayment, attributes)

    let(:loan) { create(:loan, unpaid_balance: 100.0, status: :disbursed, paid_at: nil) }


    describe "loan balance adjustment" do
      it "is invalid if loan is already paid" do
        paid_loan = create(:loan, unpaid_balance: 0.0, status: :paid, paid_at: Date.today)
        repayment = build(:loan_repayment, loan: paid_loan, amount: 10.0)
        expect(repayment).to_not be_valid
        expect(repayment.errors[:loan]).to include("is already marked as paid")
      end

      it "reduces the unpaid_balance by the repayment amount" do
        expect {
          create(:loan_repayment, loan: loan, amount: 30.0)
        }.to change { loan.reload.unpaid_balance }.by(-30.0)
      end

      it "marks loan as paid and sets paid_at when fully repaid" do
        create(:loan_repayment, loan: loan, amount: 100.0, payment_date: Date.today)

        loan.reload
        expect(loan.unpaid_balance).to eq(0)
        expect(loan.status).to eq("paid")
        expect(loan.paid_at).to eq(Date.today)
      end

      it "does not set paid status if unpaid_balance remains" do
        create(:loan_repayment, loan: loan, amount: 50.0)
        loan.reload

        expect(loan.unpaid_balance).to eq(50.0)
        expect(loan.status).to_not eq("paid")
        expect(loan.paid_at).to be_nil
      end

      it "does not change paid_at if already set" do
        paid_loan = create(:loan, unpaid_balance: 0.0, status: :paid, paid_at: Date.yesterday)
        repayment = build(:loan_repayment, loan: paid_loan, amount: 10.0)
        expect(repayment).to_not be_valid
        expect(repayment.errors[:loan]).to include("is already marked as paid")
      end
    end
  end
end
