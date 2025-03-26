FactoryBot.define do
  factory :role, class: "Bscf::Core::Role" do
    name { Faker::Name.name }
  end
end
