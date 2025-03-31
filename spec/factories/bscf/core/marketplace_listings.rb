FactoryBot.define do
  factory :marketplace_listing, class: 'Bscf::Core::MarketplaceListing' do
    user
    listing_type { 1 }
    allow_partial_match { false }
    preferred_delivery_date { DateTime.now.advance(days: 7) }
    expires_at { DateTime.now.advance(days: 5) }
    is_active { true }
    status { 1 }
    address
  end
end
