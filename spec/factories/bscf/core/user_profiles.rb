FactoryBot.define do
  factory :user_profile, class: "Bscf::Core::UserProfile" do
    user
    date_of_birth { Date.today }
    nationality { Faker::Address.country }
    occupation { Faker::Job.title }
    source_of_funds { Faker::Lorem.word }
    kyc_status { 1 }
    gender { 1 }
    verified_at { DateTime.now }
    verified_by { nil }
    address
    fayda_id { Faker::Alphanumeric.alpha(number: 10) }
  end
end
