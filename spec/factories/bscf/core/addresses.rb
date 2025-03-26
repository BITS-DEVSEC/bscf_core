FactoryBot.define do
  factory :address, class: "Bscf::Core::Address" do
    city { Faker::Address.city }
    sub_city { Faker::Name.name }
    woreda { Faker::Name.name }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    house_number { Faker::Address.building_number }
  end
end
