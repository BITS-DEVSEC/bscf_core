FactoryBot.define do
  factory :quotation_item, class: 'Bscf::Core::QuotationItem' do
    association :quotation
    association :rfq_item
    association :product
    quantity { rand(1..10) }
    unit_price { rand(10.0..100.0).round(2) }
    unit { 1 }
    subtotal { quantity * unit_price }
  end
end
