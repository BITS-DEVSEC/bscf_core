FactoryBot.define do
  factory :user, class: "Bscf::Core::User" do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone }
    password { rand(100000..999999).to_s }
  end
end
