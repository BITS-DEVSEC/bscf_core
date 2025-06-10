FactoryBot.define do
  factory :delivery_order, class: 'Bscf::Core::DeliveryOrder' do
    association :pickup_address, factory: :address
    association :dropoff_address, factory: :address
    association :driver, factory: :user

    driver_phone { Faker::PhoneNumber.phone_number }
    delivery_notes { Faker::Lorem.paragraph }
    estimated_delivery_time { 2.days.from_now }
    estimated_delivery_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    actual_delivery_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    delivery_start_time { nil }
    delivery_end_time { nil }
    status { :pending }
  end
end
