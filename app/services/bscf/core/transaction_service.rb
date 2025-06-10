module Bscf
  module Core
    class TransactionService
      # Create a transfer between two accounts
      # @param from_account_id [Integer] Source account ID
      # @param to_account_id [Integer] Destination account ID
      # @param amount [Decimal] Amount to transfer
      # @param description [String] Optional description
      # @return [Array<VirtualAccountTransaction>] The created transaction pair
      def self.create_transfer(from_account_id:, to_account_id:, amount:, description: nil)
        create_paired_transaction(
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount,
          transaction_type: :transfer,
          description: description
        )
      end

      # Create a deposit to an account
      # @param to_account_id [Integer] Destination account ID
      # @param amount [Decimal] Amount to deposit
      # @param description [String] Optional description
      # @return [Array<VirtualAccountTransaction>] The created transaction pair
      def self.create_deposit(to_account_id:, amount:, description: nil)
        system_account = find_or_create_system_account("DEPOSIT_ACCOUNT")

        # Ensure system account has sufficient balance for deposits
        ensure_system_account_balance(system_account, amount)

        create_paired_transaction(
          from_account_id: system_account.id,
          to_account_id: to_account_id,
          amount: amount,
          transaction_type: :deposit,
          description: description
        )
      end

      # Create a withdrawal from an account
      # @param from_account_id [Integer] Source account ID
      # @param amount [Decimal] Amount to withdraw
      # @param description [String] Optional description
      # @return [Array<VirtualAccountTransaction>] The created transaction pair
      def self.create_withdrawal(from_account_id:, amount:, description: nil)
        system_account = find_or_create_system_account("WITHDRAWAL_ACCOUNT")

        create_paired_transaction(
          from_account_id: from_account_id,
          to_account_id: system_account.id,
          amount: amount,
          transaction_type: :withdrawal,
          description: description
        )
      end

      # Create a fee transaction
      # @param from_account_id [Integer] Account to charge
      # @param amount [Decimal] Fee amount
      # @param description [String] Optional description
      # @return [Array<VirtualAccountTransaction>] The created transaction pair
      def self.create_fee(from_account_id:, amount:, description: nil)
        fee_account = find_or_create_system_account("FEE_ACCOUNT")

        create_paired_transaction(
          from_account_id: from_account_id,
          to_account_id: fee_account.id,
          amount: amount,
          transaction_type: :fee,
          description: description
        )
      end

      # Create an adjustment to an account
      # @param account_id [Integer] Account to adjust
      # @param amount [Decimal] Adjustment amount
      # @param is_debit [Boolean] Whether this is a debit (true) or credit (false)
      # @param description [String] Optional description
      # @return [VirtualAccountTransaction] The created adjustment transaction
      def self.create_adjustment(account_id:, amount:, is_debit: true, description: nil)
        reference_number = generate_reference_number

        VirtualAccountTransaction.create!(
          transaction_type: :adjustment,
          entry_type: is_debit ? :debit : :credit,
          account_id: account_id,
          amount: amount,
          reference_number: reference_number,
          description: description,
          status: :pending
        )
      end

      # Process a transaction
      # @param transaction [VirtualAccountTransaction] Transaction to process
      # @return [Boolean] Success or failure
      def self.process(transaction)
        transaction.process!
      end

      # Cancel a transaction
      # @param transaction [VirtualAccountTransaction] Transaction to cancel
      # @return [Boolean] Success or failure
      def self.cancel(transaction)
        transaction.cancel!
      end

      private

      def self.create_paired_transaction(from_account_id:, to_account_id:, amount:, transaction_type:, description: nil)
        reference_number = generate_reference_number

        ActiveRecord::Base.transaction do
          # Debit entry (from account)
          debit = VirtualAccountTransaction.create!(
            transaction_type: transaction_type,
            entry_type: :debit,
            account_id: from_account_id,
            amount: amount,
            reference_number: reference_number,
            description: description,
            status: :pending
          )

          # Credit entry (to account)
          credit = VirtualAccountTransaction.create!(
            transaction_type: transaction_type,
            entry_type: :credit,
            account_id: to_account_id,
            amount: amount,
            reference_number: reference_number,
            description: description,
            status: :pending,
            paired_transaction_id: debit.id
          )

          # Update the paired_transaction_id for the debit entry
          debit.update!(paired_transaction_id: credit.id)

          [ debit, credit ]
        end
      end

      def self.find_or_create_system_account(account_identifier)
        # Find or create a system account for external transactions
        account = VirtualAccount.find_or_create_by!(account_number: account_identifier) do |account|
          # Set default values for a new system account
          account.user_id = find_or_create_system_user.id
          account.cbs_account_number = account_identifier
          account.branch_code = "SYSTEM"
          account.product_scheme = "SAVINGS"
          account.voucher_type = "REGULAR"
          account.interest_rate = 0
          account.interest_type = :simple
          account.balance = 100000.00  # Initialize with a large balance
          account.locked_amount = 0
          account.status = :active
        end

        account
      end

      def self.ensure_system_account_balance(account, required_amount)
        # Top up the system account if needed
        if account.balance < required_amount
          account.update!(balance: account.balance + required_amount * 2)
        end
      end

      def self.find_or_create_system_user
        User.find_or_create_by!(phone_number: "SYSTEM_USER") do |user|
          user.first_name = "System"
          user.last_name = "User"
          user.password = SecureRandom.hex(8)
        end
      end

      def self.generate_reference_number
        timestamp = Time.current.strftime("%Y%m%d%H%M%S")
        random = SecureRandom.hex(3)
        "TXN#{timestamp}#{random}"
      end
    end
  end
end
