FactoryBot.define do
  factory :quotation, class: 'Bscf::Core::Quotation' do
    association :request_for_quotation
    association :business
    price { Faker::Commerce.price }
    delivery_date { Faker::Date.forward(days: 30) }
    valid_until { Faker::Time.forward(days: 30) }
    status { :draft }
    notes { Faker::Lorem.paragraph }

    trait :submitted do
      status { :submitted }
    end

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :expired do
      status { :expired }
      valid_until { 1.day.ago }
    end
  end
end
