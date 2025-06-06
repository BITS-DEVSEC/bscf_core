FactoryBot.define do
  factory :virtual_account, class: 'Bscf::Core::VirtualAccount' do
    association :user, factory: :user

    sequence(:cbs_account_number) { |n| "CBS#{n.to_s.rjust(8, '0')}" }
    branch_code { "BR001" }
    product_scheme { "SAVINGS" }
    voucher_type { "REGULAR" }
    balance { 0.0 }
    interest_rate { 2.5 }
    interest_type { :simple }
    active { true }
    locked_amount { 0.0 }
    status { :pending }

    trait :active_status do
      status { :active }
    end

    trait :with_balance do
      balance { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    end

    trait :compound_interest do
      interest_type { :compound }
      interest_rate { 5.0 }
    end

    trait :current_account do
      product_scheme { "CURRENT" }
      interest_rate { 0.0 }
    end

    trait :loan_account do
      product_scheme { "LOAN" }
      interest_rate { 12.5 }
    end


    trait :with_locked_amount do
      locked_amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
      balance { locked_amount + Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    end
  end
end
