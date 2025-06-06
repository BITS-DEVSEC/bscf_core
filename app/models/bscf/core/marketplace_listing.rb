module Bscf
  module Core
    class MarketplaceListing < ApplicationRecord
      belongs_to :user
      belongs_to :address
      belongs_to :product

      validates :listing_type, :status, :is_active, :price, presence: true

      enum :listing_type, { buy: 0, sell: 1 }
      enum :status, { open: 0, partially_matched: 1, matched: 2, completed: 3, cancelled: 4 }
    end
  end
end
