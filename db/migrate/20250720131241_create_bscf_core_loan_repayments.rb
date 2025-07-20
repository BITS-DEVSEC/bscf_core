class CreateBscfCoreLoanRepayments < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_loan_repayments do |t|
      t.references :loan, null: false, foreign_key: { to_table: :bscf_core_loans }
      t.references :repayment_transaction, null: false, foreign_key: { to_table: :bscf_core_virtual_account_transactions }
      t.float :amount, null: false
      t.date :payment_date, null: false, default: Date.today

      t.timestamps
    end
  end
end
