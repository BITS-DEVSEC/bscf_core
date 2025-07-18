require 'rails_helper'

module Bscf
  module Core
    RSpec.describe InvoiceItem, type: :model do
      attributes = [
        { invoice: :belong_to },
        { order_item: :belong_to },
        { description: :presence },
        { quantity: [ :presence, :numericality ] },
        { unit_price: [ :presence, :numericality ] },
        { subtotal: [ :presence, :numericality ] }
      ]

      include_examples("model_shared_spec", :invoice_item, attributes)

      describe 'validations' do
        it { should validate_numericality_of(:quantity).is_greater_than(0) }
        it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
        it { should validate_numericality_of(:subtotal).is_greater_than_or_equal_to(0) }
      end

      describe '#calculate_subtotal' do
        it 'calculates subtotal before save' do
          invoice_item = create(:invoice_item, quantity: 5)
          expect(invoice_item.unit_price).to eq(invoice_item.order_item.unit_price)
          expect(invoice_item.subtotal).to eq(invoice_item.unit_price * invoice_item.quantity)
        end
      end
    end
  end
end
