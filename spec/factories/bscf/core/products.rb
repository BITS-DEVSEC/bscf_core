FactoryBot.define do
  factory :product, class: 'Bscf::Core::Product' do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    association :category, factory: :category
    base_price { Faker::Commerce.price(range: 0..1000.0) }
  end
end
