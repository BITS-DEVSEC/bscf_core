FactoryBot.define do
  factory :business, class: 'Bscf::Core::Business' do
    user
    business_name { Faker::Company.name }
    tin_number { Faker::Number.unique.number(digits: 10).to_s }
    business_type { :retailer }
    verification_status { :pending }
    verified_at { nil }

    trait :wholesaler do
      business_type { :wholesaler }
    end

    trait :approved do
      verification_status { :approved }
      verified_at { Time.current }
    end

    trait :rejected do
      verification_status { :rejected }
      verified_at { Time.current }
    end
  end
end
