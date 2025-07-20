FactoryBot.define do
  factory :loan_repayment, class: 'Bscf::Core::LoanRepayment' do
    association :loan, factory: :loan
    association :repayment_transaction, factory: :virtual_account_transaction

    amount { 1.5 }
    payment_date { Date.today }
  end
end
