FactoryBot.define do
  factory :virtual_account_transaction, class: 'Bscf::Core::VirtualAccountTransaction' do
    association :account, factory: :virtual_account, status: :active, balance: 10000
    amount { 100.0 }
    transaction_type { :adjustment }
    entry_type { :debit }
    status { :pending }
    value_date { Time.current }
    description { Faker::Lorem.sentence }
    running_balance { nil }

    factory :paired_transaction do
      transient do
        paired_account { create(:virtual_account, status: :active, balance: 10000) }
        is_credit { false }
      end

      after(:build) do |transaction, evaluator|
        if transaction.transaction_type == 'transfer'
          paired_entry_type = transaction.entry_type == 'debit' ? :credit : :debit
        elsif transaction.transaction_type == 'deposit'
          paired_entry_type = transaction.entry_type == 'debit' ? :credit : :debit
        elsif transaction.transaction_type == 'withdrawal'
          paired_entry_type = transaction.entry_type == 'debit' ? :credit : :debit
        else
          paired_entry_type = evaluator.is_credit ? :credit : :debit
        end

        paired = build(:virtual_account_transaction,
          transaction_type: transaction.transaction_type,
          entry_type: paired_entry_type,
          account: evaluator.paired_account,
          amount: transaction.amount,
          reference_number: transaction.reference_number,
          value_date: transaction.value_date,
          status: transaction.status
        )

        transaction.paired_transaction = paired
        paired.paired_transaction = transaction
      end

      after(:create) do |transaction, evaluator|
        # Save the paired transaction after the main transaction is created
        transaction.paired_transaction.save! if transaction.paired_transaction&.new_record?
      end
    end
  end
end
