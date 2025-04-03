require 'rails_helper'

module Bscf
  module Core
    RSpec.describe MarketplaceListing, type: :model do
      attributes = [
        { user: :belong_to },
        { address: :belong_to },
        { listing_type: :presence },
        { status: :presence },
        { is_active: :presence }
      ]
      include_examples("model_shared_spec", :marketplace_listing, attributes)
    end
  end
end
