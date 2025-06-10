FactoryBot.define do
  factory :delivery_order_item, class: 'Bscf::Core::DeliveryOrderItem' do
    association :delivery_order
    association :order_item
    association :pickup_address, factory: :address
    association :dropoff_address, factory: :address
    quantity { order_item.quantity }
    status { :pending }
    notes { Faker::Lorem.paragraph }
  end
end
