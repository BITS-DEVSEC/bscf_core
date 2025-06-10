module Bscf
  module Core
    class VirtualAccountTransaction < ApplicationRecord
      belongs_to :account, class_name: "Bscf::Core::VirtualAccount"
      belongs_to :paired_transaction, class_name: "Bscf::Core::VirtualAccountTransaction", optional: true

      validates :account_id, presence: true
      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :transaction_type, presence: true
      validates :entry_type, presence: true
      validates :status, presence: true
      validates :reference_number, presence: true, uniqueness: true

      enum :transaction_type, {
        transfer: 0,
        deposit: 1,
        withdrawal: 2,
        fee: 3,      
        adjustment: 4 
      }

      enum :entry_type, {
        debit: 0,
        credit: 1
      }

      enum :status, {
        pending: 0,
        completed: 1,
        failed: 2,
        cancelled: 3
      }

      before_validation :generate_reference_number, on: :create
      validate :validate_transaction, on: :create

      scope :debits, -> { where(entry_type: :debit) }
      scope :credits, -> { where(entry_type: :credit) }
      scope :for_account, ->(account_id) { where(account_id: account_id) }
      scope :by_type, ->(type) { where(transaction_type: type) }
      scope :by_status, ->(status) { where(status: status) }
      
      def process!
        return false unless pending?

        ActiveRecord::Base.transaction do
          update_account_balance
          
          update!(status: :completed)
          paired_transaction&.update!(status: :completed)
        end
        true
      rescue StandardError => e
        update(status: :failed)
        paired_transaction&.update(status: :failed)
        Rails.logger.error("Transaction processing failed: #{e.message}")
        false
      end

      def cancel!
        return false unless pending?
        
        ActiveRecord::Base.transaction do
          update(status: :cancelled)
          paired_transaction&.update(status: :cancelled)
        end
        true
      end

      private

      def validate_transaction
        errors.add(:account, "must be active") unless account.active?
        
        if debit? && !adjustment? && account.balance.to_d < amount.to_d
          errors.add(:account, "insufficient balance")
        end
        
        if transfer? && paired_transaction.blank?
          errors.add(:paired_transaction, "must be present for transfers")
        end
      end

      def update_account_balance
        account.with_lock do
          new_balance = if debit?
                          (account.balance - amount).round(2)
                        else
                          (account.balance + amount).round(2)
                        end
          
          account.update!(balance: new_balance)
          update!(running_balance: new_balance)
        end
        
        if paired_transaction.present?
          paired_transaction.account.with_lock do
            new_balance = if paired_transaction.debit?
                            (paired_transaction.account.balance - paired_transaction.amount).round(2)
                          else
                            (paired_transaction.account.balance + paired_transaction.amount).round(2)
                          end
            
            paired_transaction.account.update!(balance: new_balance)
            paired_transaction.update!(running_balance: new_balance)
          end
        end
      end

      def generate_reference_number
        return if reference_number.present?

        timestamp = Time.current.strftime("%Y%m%d%H%M%S")
        random = SecureRandom.hex(3)
        self.reference_number = "TXN#{timestamp}#{random}"
      end
    end
  end
end
