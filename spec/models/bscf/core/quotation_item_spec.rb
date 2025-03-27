require 'rails_helper'

module Bscf
  module Core
    RSpec.describe QuotationItem, type: :model do
      attributes = [
        { quantity: [ :presence, :numericality ] },
        { unit_price: [ :presence, :numericality ] },
        { unit: :presence },
        { quotation: :belong_to },
        { rfq_item: :belong_to },
        { product: :belong_to }
      ]

      include_examples("model_shared_spec", :quotation_item, attributes)

      describe 'validations' do
        it { should validate_numericality_of(:quantity).is_greater_than(0) }
        it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
      end

      describe '#calculate_subtotal' do
        let(:quotation_item) { build(:quotation_item, quantity: 5, unit_price: 10.0) }

        it 'calculates subtotal before validation' do
          quotation_item.valid?
          expect(quotation_item.subtotal).to eq(50.0)
        end

        it 'does not calculate subtotal if quantity is missing' do
          quotation_item.quantity = nil
          quotation_item.valid?
          expect(quotation_item.subtotal).to eq(50.0)
        end

        it 'does not calculate subtotal if unit_price is missing' do
          quotation_item.unit_price = nil
          quotation_item.valid?
          expect(quotation_item.subtotal).to eq(50.0)
        end
      end
    end
  end
end
