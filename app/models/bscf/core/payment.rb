module Bscf
  module Core
    class Payment < ApplicationRecord
      belongs_to :invoice
      belongs_to :virtual_account_transaction, class_name: 'Bscf::Core::VirtualAccountTransaction', optional: true
      
      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :payment_method, :status, presence: true
      validates :reference_number, presence: true, uniqueness: true
      
      enum :payment_method, {
        cash: 0,
        virtual_account: 1
      }
      
      enum :status, {
        pending: 0,
        completed: 1,
        failed: 2,
        refunded: 3
      }
      
      before_validation :generate_reference_number, on: :create
      after_save :update_invoice_status, if: -> { saved_change_to_status? && status == 'completed' }
      
      private
      
      def generate_reference_number
        return if reference_number.present?
        
        timestamp = Time.current.strftime('%Y%m%d%H%M%S')
        random_suffix = SecureRandom.hex(3)
        self.reference_number = "PAY#{timestamp}#{random_suffix}"
      end
      
      def update_invoice_status
        total_paid = invoice.payments.completed.sum(:amount)
        
        if total_paid >= invoice.total_amount
          invoice.update(status: :paid)
        elsif total_paid > 0
          invoice.update(status: :partially_paid)
        end
      end
    end
  end
end