module Bscf
  module Core
    class VirtualAccountTransaction < ApplicationRecord
      belongs_to :account, class_name: "Bscf::Core::VirtualAccount"
      belongs_to :paired_transaction, class_name: "Bscf::Core::VirtualAccountTransaction", optional: true
      has_one :inverse_paired_transaction, class_name: "Bscf::Core::VirtualAccountTransaction", 
              foreign_key: :paired_transaction_id

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
      scope :transfers, -> { where(transaction_type: :transfer) }
      scope :deposits, -> { where(transaction_type: :deposit) }
      scope :withdrawals, -> { where(transaction_type: :withdrawal) }
      scope :fees, -> { where(transaction_type: :fee) }
      scope :adjustments, -> { where(transaction_type: :adjustment) }
      scope :by_date_range, ->(start_date, end_date) { where(value_date: start_date..end_date) }
      scope :successful, -> { where(status: :completed) }
      scope :pending, -> { where(status: :pending) }
      scope :failed, -> { where(status: :failed) }
      
      def from_account
        return nil unless debit? && paired_transaction.present?
        account
      end

      def to_account
        return nil unless credit? && paired_transaction.present?
        account
      end

      def from_account_id
        return nil unless debit? && paired_transaction.present?
        account_id
      end

      def to_account_id
        return nil unless credit? && paired_transaction.present?
        account_id
      end

      def transfer?
        transaction_type.to_sym == :transfer
      end

      def deposit?
        transaction_type.to_sym == :deposit
      end

      def withdrawal?
        transaction_type.to_sym == :withdrawal
      end

      def fee?
        transaction_type.to_sym == :fee
      end

      def adjustment?
        transaction_type.to_sym == :adjustment
      end

      def process!
        return false unless pending?

        ActiveRecord::Base.transaction do
          process_transaction
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
        case transaction_type.to_sym
        when :transfer
          validate_transfer
        when :withdrawal
          validate_withdrawal
        when :deposit
          validate_deposit
        when :fee
          validate_fee
        when :adjustment
          validate_adjustment
        end
      end

      def validate_transfer
        if debit?
          errors.add(:account, "must be active") unless account.active?
          errors.add(:account, "insufficient balance") if account.balance.to_d < amount.to_d
          errors.add(:paired_transaction, "must be present for transfers") unless paired_transaction.present?
        elsif credit?
          errors.add(:account, "must be active") unless account.active?
          errors.add(:paired_transaction, "must be present for transfers") unless paired_transaction.present?
        end
      end

      def validate_withdrawal
        if debit?
          errors.add(:account, "must be active") unless account.active?
          errors.add(:account, "insufficient balance") if account.balance.to_d < amount.to_d
          errors.add(:paired_transaction, "must be present for withdrawals") unless paired_transaction.present?
        elsif credit?
          errors.add(:paired_transaction, "must be present for withdrawals") unless paired_transaction.present?
        end
      end

      def validate_deposit
        if credit?
          errors.add(:account, "must be active") unless account.active?
          errors.add(:paired_transaction, "must be present for deposits") unless paired_transaction.present?
        elsif debit?
          errors.add(:paired_transaction, "must be present for deposits") unless paired_transaction.present?
        end
      end

      def validate_fee
        if debit?
          errors.add(:account, "must be active") unless account.active?
          errors.add(:account, "insufficient balance") if account.balance.to_d < amount.to_d
          errors.add(:paired_transaction, "must be present for fees") unless paired_transaction.present?
        elsif credit?
          errors.add(:paired_transaction, "must be present for fees") unless paired_transaction.present?
        end
      end

      def validate_adjustment
        errors.add(:account, "must be active") unless account.active?
        if debit? && account.balance.to_d < amount.to_d
          errors.add(:account, "insufficient balance for debit adjustment")
        end
      end

      def process_transaction
        case transaction_type.to_sym
        when :transfer
          process_transfer
        when :withdrawal
          process_withdrawal
        when :deposit
          process_deposit
        when :fee
          process_fee
        when :adjustment
          process_adjustment
        end
      end

      def process_transfer
        if debit?
          account.with_lock do
            new_balance = (account.balance - amount).round(2)
            account.update!(balance: new_balance)
            update!(running_balance: new_balance)
          end
        elsif credit?
          account.with_lock do
            new_balance = (account.balance + amount).round(2)
            account.update!(balance: new_balance)
            update!(running_balance: new_balance)
          end
        end
      end

      def process_withdrawal
        if debit?
          account.with_lock do
            new_balance = (account.balance - amount).round(2)
            account.update!(balance: new_balance)
            update!(running_balance: new_balance)
          end
        elsif credit?
          if account.system?
            account.with_lock do
              new_balance = (account.balance + amount).round(2)
              account.update!(balance: new_balance)
              update!(running_balance: new_balance)
            end
          end
        end
      end

      def process_deposit
        if credit?
          account.with_lock do
            new_balance = (account.balance + amount).round(2)
            account.update!(balance: new_balance)
            update!(running_balance: new_balance)
          end
        elsif debit?
          if account.system?
            account.with_lock do
              new_balance = (account.balance - amount).round(2)
              account.update!(balance: new_balance)
              update!(running_balance: new_balance)
            end
          end
        end
      end

      def process_fee
        if debit?
          account.with_lock do
            new_balance = (account.balance - amount).round(2)
            account.update!(balance: new_balance)
            update!(running_balance: new_balance)
          end
        elsif credit?
          if account.system?
            account.with_lock do
              new_balance = (account.balance + amount).round(2)
              account.update!(balance: new_balance)
              update!(running_balance: new_balance)
            end
          end
        end
      end

      def process_adjustment
        account.with_lock do
          if debit?
            new_balance = (account.balance - amount).round(2)
          else 
            new_balance = (account.balance + amount).round(2)
          end
          account.update!(balance: new_balance)
          update!(running_balance: new_balance)
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
