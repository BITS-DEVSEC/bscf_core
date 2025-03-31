FactoryBot.define do
  factory :delivery_order_item, class: 'Bscf::Core::DeliveryOrderItem' do
    association :delivery_order
    association :order_item
    association :product
    quantity { order_item.quantity }
    status { :pending }
    notes { Faker::Lorem.paragraph }
  end
end
