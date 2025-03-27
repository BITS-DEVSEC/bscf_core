module Bscf
  module Core
    class QuotationItem < ApplicationRecord
      belongs_to :quotation
      belongs_to :rfq_item
      belongs_to :product

      validates :quantity, presence: true, numericality: { greater_than: 0 }
      validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :unit, presence: true
      validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }

      before_validation :calculate_subtotal

      private

      def calculate_subtotal
        return unless quantity.present? && unit_price.present?
        self.subtotal = quantity * unit_price
      end
    end
  end
end
