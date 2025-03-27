FactoryBot.define do
  factory :order_item, class: "Bscf::Core::OrderItem" do
    order
    product
    quotation_item
    quantity { Faker::Number.between(from: 1, to: 15) }
    unit_price { Faker::Number.between(from: 10, to: 100) }
    subtotal { Faker::Number.between(from: 200, to: 15000) }
  end
end
