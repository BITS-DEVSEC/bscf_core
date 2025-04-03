module Bscf::Core
  class WholesalerProduct < ApplicationRecord
    belongs_to :business
    belongs_to :product

    validates :minimum_order_quantity, presence: true, numericality: { greater_than: 0 }
    validates :wholesale_price, presence: true, numericality: { greater_than: 0 }
    validates :available_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :status, presence: true

    validate :business_must_be_wholesaler
    validate :unique_product_per_wholesaler

    enum :status, {
      active: 0,
      inactive: 1,
      out_of_stock: 2
    }

    private

    def business_must_be_wholesaler
      if business && !business.wholesaler?
        errors.add(:business, "must be a wholesaler")
      end
    end

    def unique_product_per_wholesaler
      if WholesalerProduct.where(business: business, product: product)
                         .where.not(id: id)
                         .exists?
        errors.add(:product, "already exists for this wholesaler")
      end
    end
  end
end
