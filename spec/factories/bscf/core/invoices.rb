FactoryBot.define do
  factory :invoice, class: 'Bscf::Core::Invoice' do
    order
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    tax_amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    discount_amount { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    total_amount { amount + tax_amount - discount_amount }
    due_date { Time.current + 30.days }
    status { :draft }
    notes { Faker::Lorem.paragraph }
  end
end
