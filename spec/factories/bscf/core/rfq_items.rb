FactoryBot.define do
  factory :rfq_item, class: "Bscf::Core::RfqItem" do
    request_for_quotation
    product
    quantity { Faker::Number.between(from: 1, to: 20) }
    notes { Faker::Lorem.sentence }
  end
end
