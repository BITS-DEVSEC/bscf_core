FactoryBot.define do
  factory :virtual_account_transaction, class: 'Bscf::Core::VirtualAccountTransaction' do
    association :from_account, factory: :virtual_account, status: :active, balance: 10000
    association :to_account, factory: :virtual_account, status: :active, balance: 5000
    amount { 100.0 }
    transaction_type { :transfer }
    status { :pending }
    description { Faker::Lorem.sentence }

    trait :completed do
      status { :completed }
    end

    trait :failed do
      status { :failed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :deposit do
      transaction_type { :deposit }
    end

    trait :withdrawal do
      transaction_type { :withdrawal }
    end

    trait :with_large_amount do
      amount { 5000.0 }
    end
  end
end
