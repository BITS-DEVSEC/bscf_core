FactoryBot.define do
  factory :invoice_item, class: 'Bscf::Core::InvoiceItem' do
    invoice
    order_item
    description { Faker::Commerce.product_name }
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
