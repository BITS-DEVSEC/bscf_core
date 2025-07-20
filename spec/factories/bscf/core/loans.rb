FactoryBot.define do
  factory :loan, class: 'Bscf::Core::Loan' do
    association :virtual_account
    association :disbursement_transaction, factory: :virtual_account_transaction

    principal_amount { 1.5 }
    interest_amount { 1.5 }
    unpaid_balance { 1.5 }
    status { 1 }
    due_date { Date.today + 15.days }
  end
end
