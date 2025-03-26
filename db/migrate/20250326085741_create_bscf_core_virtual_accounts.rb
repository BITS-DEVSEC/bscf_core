class CreateBscfCoreVirtualAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_virtual_accounts do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.string :account_number, null: false
      t.string :cbs_account_number, null: false
      t.decimal :balance, null: false, default: 0
      t.decimal :interest_rate, null: false, default: 0
      t.integer :interest_type, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string :branch_code, null: false
      t.string :product_scheme, null: false
      t.string :voucher_type, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :bscf_core_virtual_accounts, :account_number, unique: true
    add_index :bscf_core_virtual_accounts, :cbs_account_number, unique: true
    add_index :bscf_core_virtual_accounts, :branch_code
    add_index :bscf_core_virtual_accounts, [ :user_id, :account_number ]
  end
end
