require 'rails_helper'

module Bscf
  module Core
    RSpec.describe RfqItem, type: :model do
      attributes = [
        { request_for_quotation: :belong_to },
        { product: :belong_to },
        { quantity: :presence }
      ]
      include_examples("model_shared_spec", :rfq_item, attributes)
    end
  end
end
