FactoryBot.define do
  factory :product, class: 'Bscf::Core::Product' do
    category
    sequence(:sku) { |n| "SKU-#{n}" }
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }

    after(:build) do |product|
      product.thumbnail.attach(
        io: StringIO.new("test image"),
        filename: 'thumbnail.jpg',
        content_type: 'image/jpeg'
      )
    end

    trait :with_images do
      after(:build) do |product|
        2.times do |i|
          product.images.attach(
            io: StringIO.new("test image #{i}"),
            filename: "image_#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end
      end
    end
  end
end
