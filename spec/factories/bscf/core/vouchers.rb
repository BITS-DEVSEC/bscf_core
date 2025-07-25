FactoryBot.define do
  factory :voucher, class: 'Bscf::Core::Voucher' do
    association :issued_by, factory: :user

    before(:create) do |voucher|
      create(:virtual_account, user: voucher.issued_by, balance: 10000.0)
    end

    full_name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    amount { 100 }
    expires_at { 30.days.from_now }
    status { :pending }

    trait :active do
      status { :active }
      after(:create) do |voucher|
        voucher.issued_by.virtual_account.update!(balance: voucher.amount + 1000)
        voucher.send(:lock_issuer_amount)
      end
    end

    trait :redeemed do
      status { :redeemed }
      redeemed_at { Time.current }
    end

    trait :expired do
      status { :expired }
      expires_at { 1.day.ago }
    end

    trait :returned do
      status { :returned }
      returned_at { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
      returned_at { Time.current }
    end

    trait :with_sufficient_balance do
      after(:build) do |voucher|
        voucher.issued_by.virtual_account.update!(balance: voucher.amount + 1000)
      end
    end
  end
end
