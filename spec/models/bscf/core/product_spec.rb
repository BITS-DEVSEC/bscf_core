require 'rails_helper'

module Bscf::Core
  RSpec.describe Product, type: :model do
    attributes = [
      { sku: [ :presence, :uniqueness ] },
      { name: [ :presence ] },
      { description: [ :presence ] },
      { base_price: [ :presence ] },
      { category: :belong_to }
    ]

    include_examples("model_shared_spec", :product, attributes)

    describe 'SKU generation' do
      let(:category) { create(:category) }

      it 'generates SKU automatically' do
        product = create(:product, category: category)
        expect(product.sku).to match(/\ABSC\d{7}\z/)
      end

      it 'generates sequential SKUs for same category' do
        first_product = create(:product, category: category)
        second_product = create(:product, category: category)

        first_sequence = first_product.sku[-4..-1].to_i
        second_sequence = second_product.sku[-4..-1].to_i

        expect(second_sequence).to eq(first_sequence + 1)
      end

      it 'maintains category code in SKU' do
        product = create(:product, category: category)
        category_code = category.id.to_s.rjust(3, '0')
        expect(product.sku[3..5]).to eq(category_code)
      end

      it 'does not modify existing SKU' do
        product = create(:product, category: category)
        original_sku = product.sku
        product.update(name: 'Updated Name')
        expect(product.reload.sku).to eq(original_sku)
      end
    end
  end
end
