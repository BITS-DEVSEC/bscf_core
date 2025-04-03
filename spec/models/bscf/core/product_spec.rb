require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Product, type: :model do
      attributes = [
        { sku: [ :presence, :uniqueness ] },
        { name: :presence },
        { description: :presence },
        { base_price: :presence },
        { category: :belong_to }
      ]

      include_examples("model_shared_spec", :product, attributes)

      describe 'image attachments' do
        describe 'thumbnail' do
          let(:product) { build(:product) }

          it 'accepts valid image formats' do
            product.thumbnail.attach(
              io: StringIO.new('test image'),
              filename: 'thumbnail.jpg',
              content_type: 'image/jpeg'
            )
            expect(product).to be_valid
          end
        end

        describe 'multiple images' do
          let(:product) { build(:product, :with_images) }

          it 'allows multiple image attachments' do
            expect(product.images.count).to eq(2)
            expect(product).to be_valid
          end
        end
      end
    end
  end
end
