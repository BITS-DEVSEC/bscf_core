FactoryBot.define do
  factory :category, class: 'Bscf::Core::Category' do
    name { Faker::Commerce.department }
    description { Faker::Lorem.sentence }

    trait :with_parent do
      association :parent, factory: :category
    end

    trait :with_children do
      after(:create) do |category|
        create_list(:category, 2, parent: category)
      end
    end
  end
end
