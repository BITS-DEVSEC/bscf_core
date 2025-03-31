FactoryBot.define do
  factory :delivery_order, class: 'Bscf::Core::DeliveryOrder' do
    association :order
    association :delivery_address, factory: :address
    contact_phone { Faker::PhoneNumber.phone_number }
    delivery_notes { Faker::Lorem.paragraph }
    estimated_delivery_time { 2.days.from_now }
    actual_delivery_time { nil }
    status { :pending }
  end
end
