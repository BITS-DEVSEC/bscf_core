FactoryBot.define do
  factory :vehicle, class: 'Bscf::Core::Vehicle' do
    association :driver, factory: :user
    sequence(:plate_number) { |n| "ABC#{n}123" }
    vehicle_type { ['Truck', 'Van', 'Pickup'].sample }
    brand { ['Toyota', 'Ford', 'Mercedes', 'Volvo'].sample }
    model { ['Hilux', 'Transit', 'Actros', 'FH16'].sample }
    year { rand(2015..Time.current.year) }
    color { ['White', 'Black', 'Silver', 'Blue'].sample }
  end
end
