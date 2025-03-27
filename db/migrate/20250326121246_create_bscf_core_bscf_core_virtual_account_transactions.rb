class CreateBscfCoreBscfCoreVirtualAccountTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_virtual_account_transactions do |t|
      t.references :from_account, null: false, foreign_key: { to_table: :bscf_core_virtual_accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :bscf_core_virtual_accounts }
      t.decimal :amount, null: false
      t.integer :transaction_type, null: false
      t.integer :status, null: false, default: 0
      t.string :reference_number, null: false
      t.text :description

      t.timestamps
    end

    add_index :bscf_core_virtual_account_transactions, :reference_number, unique: true
    add_index :bscf_core_virtual_account_transactions, [ :from_account_id, :reference_number ]
    add_index :bscf_core_virtual_account_transactions, [ :to_account_id, :reference_number ]
  end
end
