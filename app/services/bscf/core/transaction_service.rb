module Bscf
  module Core
    class TransactionService
      # External account identifiers
      EXTERNAL_SOURCES = {
        bank_transfer: 'BANK_TRANSFER_ACCOUNT',
        credit_card: 'CREDIT_CARD_ACCOUNT',
        mobile_money: 'MOBILE_MONEY_ACCOUNT',
        cash: 'CASH_ACCOUNT'
      }
      
      def initialize(user = nil)
        @user = user
      end
      
      def create_transfer(from_account_id, to_account_id, amount, reference_number = nil, value_date = nil)
        ActiveRecord::Base.transaction do
          # Debit entry (from account)
          debit = VirtualAccountTransaction.create!(
            transaction_type: :transfer,
            entry_type: :debit,
            account_id: from_account_id,
            amount: amount,
            reference_number: reference_number || generate_reference_number,
            value_date: value_date || Time.current,
            status: :pending
          )
          
          # Credit entry (to account)
          credit = VirtualAccountTransaction.create!(
            transaction_type: :transfer,
            entry_type: :credit,
            account_id: to_account_id,
            amount: amount,
            reference_number: debit.reference_number,
            value_date: debit.value_date,
            status: :pending,
            paired_transaction_id: debit.id
          )
          
          # Update the paired_transaction_id for the debit entry
          debit.update!(paired_transaction_id: credit.id)
          
          [debit, credit]
        end
      end
      
      def create_deposit(to_account_id, amount, source = :bank_transfer, reference_number = nil, value_date = nil)
        external_account = find_or_create_system_account(EXTERNAL_SOURCES[source])
        
        ActiveRecord::Base.transaction do
          # Debit entry (external account)
          debit = VirtualAccountTransaction.create!(
            transaction_type: :deposit,
            entry_type: :debit,
            account_id: external_account.id,
            amount: amount,
            reference_number: reference_number || generate_reference_number,
            value_date: value_date || Time.current,
            status: :pending
          )
          
          # Credit entry (user account)
          credit = VirtualAccountTransaction.create!(
            transaction_type: :deposit,
            entry_type: :credit,
            account_id: to_account_id,
            amount: amount,
            reference_number: debit.reference_number,
            value_date: debit.value_date,
            status: :pending,
            paired_transaction_id: debit.id
          )
          
          # Update the paired_transaction_id for the debit entry
          debit.update!(paired_transaction_id: credit.id)
          
          [debit, credit]
        end
      end
      
      # Create a withdrawal from a user account to a specific external source
      def create_withdrawal(from_account_id, amount, destination = :bank_transfer, reference_number = nil, value_date = nil)
        external_account = find_or_create_system_account(EXTERNAL_SOURCES[destination])
        
        ActiveRecord::Base.transaction do
          # Debit entry (user account)
          debit = VirtualAccountTransaction.create!(
            transaction_type: :withdrawal,
            entry_type: :debit,
            account_id: from_account_id,
            amount: amount,
            reference_number: reference_number || generate_reference_number,
            value_date: value_date || Time.current,
            status: :pending
          )
          
          # Credit entry (external account)
          credit = VirtualAccountTransaction.create!(
            transaction_type: :withdrawal,
            entry_type: :credit,
            account_id: external_account.id,
            amount: amount,
            reference_number: debit.reference_number,
            value_date: debit.value_date,
            status: :pending,
            paired_transaction_id: debit.id
          )
          
          # Update the paired_transaction_id for the debit entry
          debit.update!(paired_transaction_id: credit.id)
          
          [debit, credit]
        end
      end
      
      # Process a transaction (both the transaction and its pair)
      def process_transaction(transaction_id)
        transaction = VirtualAccountTransaction.find(transaction_id)
        
        return false unless transaction.status == 'pending'
        
        ActiveRecord::Base.transaction do
          # Lock accounts to prevent race conditions
          account = transaction.account.lock!
          paired_transaction = transaction.paired_transaction
          paired_account = paired_transaction.account.lock! if paired_transaction
          
          # Update account balances based on entry type
          if transaction.entry_type == 'debit'
            raise "Insufficient balance" if account.balance < transaction.amount
            
            new_balance = account.balance - transaction.amount
            account.update!(balance: new_balance)
            transaction.update!(running_balance: new_balance)
            
            if paired_transaction && paired_account
              new_paired_balance = paired_account.balance + transaction.amount
              paired_account.update!(balance: new_paired_balance)
              paired_transaction.update!(running_balance: new_paired_balance)
            end
          else 
            new_balance = account.balance + transaction.amount
            account.update!(balance: new_balance)
            transaction.update!(running_balance: new_balance)
            
            if paired_transaction && paired_account
              new_paired_balance = paired_account.balance - transaction.amount
              paired_account.update!(balance: new_paired_balance)
              paired_transaction.update!(running_balance: new_paired_balance)
            end
          end
          
          transaction.update!(status: :completed)
          paired_transaction.update!(status: :completed) if paired_transaction
          
          true
        end
      rescue => e
        transaction.update(status: :failed)
        transaction.paired_transaction&.update(status: :failed)
        
        raise e
      end
      
      private
      
      def find_or_create_system_account(identifier)
        VirtualAccount.find_or_create_by!(account_number: identifier) do |account|
          account.name = identifier.titleize
          account.account_type = :system
          account.status = :active
        end
      end
      
      def generate_reference_number
        "TXN-#{SecureRandom.hex(8).upcase}"
      end
    end
  end
end