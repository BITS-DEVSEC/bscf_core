FactoryBot.define do
  factory :loan, class: 'Bscf::Core::Loan' do
    association :virtual_account
    association :disbursement_transaction, factory: :virtual_account_transaction

    principal_amount { 200.5 }
    interest_amount { 10.5 }
    unpaid_balance { 210.5 }
    status { 0 }
    due_date { Date.today + 15.days }
  end
end
