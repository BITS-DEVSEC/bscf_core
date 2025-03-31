require 'rails_helper'

module Bscf
  module Core
    RSpec.describe DeliveryOrderItem, type: :model do
      attributes = [
        { delivery_order: :belong_to },
        { order_item: :belong_to },
        { product: :belong_to },
        { quantity: :presence },
        { status: :presence }
      ]
      include_examples("model_shared_spec", :delivery_order_item, attributes)

      describe 'validations' do
        it 'validates quantity does not exceed order item quantity' do
          order_item = create(:order_item, quantity: 5)
          delivery_order_item = build(:delivery_order_item, order_item: order_item, quantity: 6)

          expect(delivery_order_item).not_to be_valid
          expect(delivery_order_item.errors[:quantity]).to include("cannot exceed order item quantity (5)")
        end
      end
    end
  end
end
