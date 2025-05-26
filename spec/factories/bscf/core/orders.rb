FactoryBot.define do
  factory :order, class: "Bscf::Core::Order" do
    ordered_by { create(:user) }
    ordered_to { create(:user) }
    quotation { create(:quotation) }
    order_type { :order_from_quote }
    status { :draft }
    total_amount { Faker::Number.between(from: 100, to: 1000) }
    delivery_order { nil } 
  end
end
