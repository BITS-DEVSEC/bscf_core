module Bscf::Core
  class OrderItem < ApplicationRecord
    belongs_to :order
    belongs_to :product
    belongs_to :quotation_item, optional: true
    before_save :calculate_subtotal


    validates :quantity, :unit_price, :subtotal, presence: true

    def calculate_subtotal
      self.subtotal = (unit_price * quantity).round(2)
    end
  end
end
