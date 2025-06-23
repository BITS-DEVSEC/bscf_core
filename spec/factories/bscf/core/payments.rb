FactoryBot.define do
  factory :payment, class: 'Bscf::Core::Payment' do
    invoice
    virtual_account_transaction { nil }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    payment_method { :virtual_account }
    status { :pending }
    reference_number { "PAY#{Time.current.strftime('%Y%m%d%H%M%S')}#{SecureRandom.hex(3)}" }
    payment_date { Time.current }
    notes { Faker::Lorem.sentence }
  end
end
