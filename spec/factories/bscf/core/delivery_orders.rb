FactoryBot.define do
  factory :delivery_order, class: 'Bscf::Core::DeliveryOrder' do
    association :order
    association :pickup_address, factory: :address
    association :dropoff_address, factory: :address
    driver { nil }

    buyer_phone { Faker::PhoneNumber.phone_number }
    seller_phone { Faker::PhoneNumber.phone_number }
    driver_phone { Faker::PhoneNumber.phone_number }
    delivery_notes { Faker::Lorem.paragraph }
    estimated_delivery_time { 2.days.from_now }
    delivery_start_time { nil }
    delivery_end_time { nil }
    status { :pending }

    trait :with_driver do
      association :driver, factory: :user
    end

    trait :in_transit do
      with_driver
      status { :in_transit }
      delivery_start_time { Time.current }
    end

    trait :delivered do
      with_driver
      status { :delivered }
      delivery_start_time { 2.hours.ago }
      delivery_end_time { Time.current }
    end
  end
end
