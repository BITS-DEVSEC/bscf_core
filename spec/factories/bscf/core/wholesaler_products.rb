FactoryBot.define do
  factory :wholesaler_product, class: 'Bscf::Core::WholesalerProduct' do
    association :business, :wholesaler
    association :product
    minimum_order_quantity { Faker::Number.between(from: 5, to: 100) }
    wholesale_price { Faker::Commerce.price(range: 50..1000.0) }
    available_quantity { Faker::Number.between(from: 100, to: 1000) }
    status { :active }
  end

  trait :inactive do
    status { :inactive }
  end

  trait :out_of_stock do
    status { :out_of_stock }
    available_quantity { 0 }
  end
end
