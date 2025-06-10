FactoryBot.define do
  factory :virtual_account_transaction, class: 'Bscf::Core::VirtualAccountTransaction' do
    association :account, factory: :virtual_account, status: :active, balance: 10000
    amount { 100.0 }
    transaction_type { :transfer }
    entry_type { :debit }
    status { :pending }
    reference_number { "TXN#{Time.current.strftime('%Y%m%d%H%M%S')}#{SecureRandom.hex(3)}" }
    value_date { Time.current }
    description { Faker::Lorem.sentence }
    running_balance { nil }

    trait :completed do
      status { :completed }
      running_balance { account.balance - amount }
    end

    trait :failed do
      status { :failed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :credit do
      entry_type { :credit }
      running_balance { account.balance + amount }
    end

    trait :debit do
      entry_type { :debit }
      running_balance { account.balance - amount }
    end

    trait :deposit do
      transaction_type { :deposit }
    end

    trait :withdrawal do
      transaction_type { :withdrawal }
    end

    trait :fee do
      transaction_type { :fee }
    end

    trait :adjustment do
      transaction_type { :adjustment }
    end

    trait :with_large_amount do
      amount { 5000.0 }
    end

    factory :paired_transaction do
      transient do
        paired_account { create(:virtual_account, status: :active, balance: 5000) }
        is_credit { true } 
      end

      after(:build) do |transaction, evaluator|
        paired = build(:virtual_account_transaction,
          transaction_type: transaction.transaction_type,
          entry_type: evaluator.is_credit ? :credit : :debit,
          account: evaluator.paired_account,
          amount: transaction.amount,
          reference_number: transaction.reference_number,
          value_date: transaction.value_date,
          status: transaction.status,
          paired_transaction: transaction
        )

        transaction.paired_transaction = paired
      end
    end
  end
end
