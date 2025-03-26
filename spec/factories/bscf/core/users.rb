FactoryBot.define do
  factory :user, class: "Bscf::Core::User" do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }
    email { Faker::Internet.email }
    phone_number { Faker::Alphanumeric.alpha(number: 10) }
  end
end
