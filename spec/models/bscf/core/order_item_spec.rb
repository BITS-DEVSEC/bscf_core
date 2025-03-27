require 'rails_helper'

module Bscf
  module Core
    RSpec.describe OrderItem, type: :model do
      attributes = [
        { order: :belong_to },
        { product: :belong_to },
        { quotation_item: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { quantity: :presence },
        { unit_price: :presence },
        { subtotal: :presence }
      ]
      include_examples("model_shared_spec", :order_item, attributes)


      describe "#calculate_subtotal" do
        it "calculates subtotal" do
          order_item = create(:order_item, quantity: 2, unit_price: 25)
          order_item.calculate_subtotal
          expect(order_item.calculate_subtotal).to eq 50.0
        end
      end
    end
  end
end
