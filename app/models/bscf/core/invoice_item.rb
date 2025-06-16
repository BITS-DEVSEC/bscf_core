module Bscf
  module Core
    class InvoiceItem < ApplicationRecord
      belongs_to :invoice, class_name: "Bscf::Core::Invoice"
      belongs_to :order_item, class_name: "Bscf::Core::OrderItem"

      validates :description, :quantity, :unit_price, :subtotal, presence: true
      validates :quantity, numericality: { greater_than: 0 }
      validates :unit_price, :subtotal, numericality: { greater_than_or_equal_to: 0 }

      before_save :calculate_subtotal

      private

      def calculate_subtotal
        self.subtotal = quantity * unit_price if quantity.present? && unit_price.present?
      end
    end
  end
end
