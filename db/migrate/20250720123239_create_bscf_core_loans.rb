class CreateBscfCoreLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_loans do |t|
      t.references :virtual_account, null: false, foreign_key: {to_table: :bscf_core_virtual_accounts}
      t.references :disbursement_transaction, null: false, foreign_key: {to_table: :bscf_core_virtual_account_transactions}
      t.float :principal_amount, null: false, default: 0.0
      t.float :interest_amount, null: false, default: 0.0
      t.float :unpaid_balance, null: false, default: 0.0
      t.integer :status, null: false, default: 0
      t.date :due_date, null: false, default: Date.today + 15.days
      t.date :paid_at, null: true

      t.timestamps
    end
  end
end
