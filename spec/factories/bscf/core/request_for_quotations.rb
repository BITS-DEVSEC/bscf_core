FactoryBot.define do
  factory :request_for_quotation, class: "Bscf::Core::RequestForQuotation" do
    user
    status { 0 }
    notes { Faker::Lorem.sentence }
  end
end
