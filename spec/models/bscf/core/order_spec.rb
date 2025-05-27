require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Order, type: :model do
      attributes = [
        { quotation: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { ordered_by: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { ordered_to: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { delivery_order: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { order_type: :presence },
        { status: :presence }
      ]
      include_examples("model_shared_spec", :order, attributes)

      describe 'associations' do
        it 'can belong to a delivery order' do
          delivery_order = create(:delivery_order)
          order = create(:order, delivery_order: delivery_order)
          expect(order.delivery_order).to eq(delivery_order)
        end
      end
    end
  end
end
