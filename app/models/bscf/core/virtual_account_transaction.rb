module Bscf
  module Core
    class VirtualAccountTransaction < ApplicationRecord
      belongs_to :from_account, class_name: "Bscf::Core::VirtualAccount", optional: true
      belongs_to :to_account, class_name: "Bscf::Core::VirtualAccount", optional: true

      validates :from_account_id, presence: true, if: :requires_from_account?
      validates :to_account_id, presence: true, if: :requires_to_account?
      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :transaction_type, presence: true
      validates :status, presence: true
      validates :reference_number, presence: true, uniqueness: true

      enum :transaction_type, {
        transfer: 0,
        deposit: 1,
        withdrawal: 2
      }

      enum :status, {
        pending: 0,
        completed: 1,
        failed: 2,
        cancelled: 3
      }

      before_validation :generate_reference_number, on: :create
      validate :validate_transaction, on: :create

      def process!
        return false unless pending?

        ActiveRecord::Base.transaction do
          process_transaction
          update!(status: :completed)
        end
        true
      rescue StandardError => e
        update(status: :failed)
        false
      end

      def cancel!
        return false unless pending?
        update(status: :cancelled)
      end

      private

      def requires_from_account?
        return false if transaction_type.nil?
        %w[transfer withdrawal].include?(transaction_type)
      end

      def requires_to_account?
        return false if transaction_type.nil?
        %w[transfer deposit].include?(transaction_type)
      end

      def validate_transaction
        case transaction_type.to_sym
        when :transfer
          validate_transfer
        when :withdrawal
          validate_withdrawal
        when :deposit
          validate_deposit
        end

        validate_account_requirements
      end

      def validate_transfer
        return unless from_account && to_account

        errors.add(:from_account, "must be active") unless from_account.active?
        errors.add(:to_account, "must be active") unless to_account.active?
        errors.add(:from_account, "insufficient balance") if from_account.balance.to_d < amount.to_d
      end

      private

      def validate_account_requirements
        case transaction_type.to_sym
        when :transfer
          return if from_account_id.present? && to_account_id.present?
          errors.add(:base, "Both accounts are required for transfer")
        when :withdrawal
          return if from_account_id.present?
          errors.add(:base, "Source account is required for withdrawal")
          errors.add(:to_account_id, "must be blank for withdrawal")
        when :deposit
          return if to_account_id.present?
          errors.add(:base, "Destination account is required for deposit")
          errors.add(:from_account_id, "must be blank for deposit")
        end
      end

      def validate_withdrawal
        return unless from_account
        errors.add(:from_account, "must be active") unless from_account.active?
        errors.add(:from_account, "insufficient balance") if from_account.balance.to_d < amount.to_d
      end

      def validate_deposit
        return unless to_account
        errors.add(:to_account, "must be active") unless to_account.active?
      end

      def process_transaction
        case transaction_type.to_sym
        when :transfer
          process_transfer
        when :withdrawal
          process_withdrawal
        when :deposit
          process_deposit
        end
      end

      def process_transfer
        ActiveRecord::Base.transaction do
          from_account.with_lock do
            to_account.with_lock do
              new_from_balance = (from_account.balance - amount).round(2)
              new_to_balance = (to_account.balance + amount).round(2)

              from_account.update!(balance: new_from_balance)
              to_account.update!(balance: new_to_balance)
            end
          end
        end
      end

      def process_withdrawal
        from_account.with_lock do
          new_balance = (from_account.balance - amount).round(2)
          from_account.update!(balance: new_balance)
        end
      end

      def process_deposit
        to_account.with_lock do
          new_balance = (to_account.balance + amount).round(2)
          to_account.update!(balance: new_balance)
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
