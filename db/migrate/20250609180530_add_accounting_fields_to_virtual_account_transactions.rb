class AddAccountingFieldsToVirtualAccountTransactions < ActiveRecord::Migration[8.0]
  def change
    # Add new accounting fields
    add_column :bscf_core_virtual_account_transactions, :entry_type, :integer
    add_reference :bscf_core_virtual_account_transactions, :account, null: false, foreign_key: { to_table: :bscf_core_virtual_accounts }
    add_column :bscf_core_virtual_account_transactions, :running_balance, :decimal, precision: 10, scale: 2
    add_reference :bscf_core_virtual_account_transactions, :paired_transaction, null: true, foreign_key: { to_table: :bscf_core_virtual_account_transactions }
    add_column :bscf_core_virtual_account_transactions, :value_date, :datetime
    
    # Add new indexes
    add_index :bscf_core_virtual_account_transactions, [:account_id, :reference_number]
    add_index :bscf_core_virtual_account_transactions, :entry_type
    
    # Remove old fields and indexes
    remove_index :bscf_core_virtual_account_transactions, [:from_account_id, :reference_number], if_exists: true
    remove_index :bscf_core_virtual_account_transactions, [:to_account_id, :reference_number], if_exists: true
    remove_reference :bscf_core_virtual_account_transactions, :from_account
    remove_reference :bscf_core_virtual_account_transactions, :to_account
  end
end
