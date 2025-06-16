module Bscf
  module Core
    class Invoice < ApplicationRecord
      belongs_to :order
      has_many :payments, dependent: :destroy 

      validates :invoice_number, presence: true, uniqueness: true
      validates :amount, :tax_amount, :discount_amount, :total_amount, presence: true,
                numericality: { greater_than_or_equal_to: 0 }
      validates :status, presence: true

      enum :status, {
        draft: 0,
        issued: 1,
        paid: 2,
        partially_paid: 3,
        overdue: 4,
        cancelled: 5
      }

      before_validation :generate_invoice_number, on: :create

      private

      def generate_invoice_number
        return if invoice_number.present?

        timestamp = Time.current.strftime("%Y%m%d%H%M%S")
        random_suffix = SecureRandom.hex(3)
        self.invoice_number = "INV#{timestamp}#{random_suffix}"
      end
    end
  end
end
