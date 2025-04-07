require 'rails_helper'

module Bscf::Core
  RSpec.describe WholesalerProduct, type: :model do
    attributes = [
      { business: :belong_to },
      { product: :belong_to },
      { minimum_order_quantity: [ :presence, :numericality ] },
      { wholesale_price: [ :presence, :numericality ] },
      { available_quantity: [ :presence, :numericality ] },
      { status: :presence }
    ]

    include_examples("model_shared_spec", :wholesaler_product, attributes)

    describe 'validations' do
      let(:wholesaler) { create(:business, :wholesaler) }
      let(:retailer) { create(:business, :retailer) }
      let(:product) { create(:product) }

      it 'allows creation with wholesaler business' do
        wholesaler_product = build(:wholesaler_product,
          business: wholesaler
        )
        expect(wholesaler_product).to be_valid
      end

      it 'prevents creation with retailer business' do
        wholesaler_product = build(:wholesaler_product,
          business: retailer
        )
        expect(wholesaler_product).not_to be_valid
        expect(wholesaler_product.errors[:business]).to include("must be a wholesaler")
      end

      it 'prevents duplicate products for the same wholesaler' do
        create(:wholesaler_product,
          business: wholesaler,
          product: product
        )
        duplicate = build(:wholesaler_product,
          business: wholesaler,
          product: product
        )

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:product]).to include("already exists for this wholesaler")
      end

      it { should validate_numericality_of(:minimum_order_quantity).is_greater_than(0) }
      it { should validate_numericality_of(:wholesale_price).is_greater_than(0) }
      it { should validate_numericality_of(:available_quantity).is_greater_than_or_equal_to(0) }
    end

    describe 'enums' do
      it { should define_enum_for(:status).with_values(active: 0, inactive: 1, out_of_stock: 2) }
    end
  end
end
