class CreateBscfCorePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_payments do |t|
      t.references :invoice, null: false, foreign_key: {to_table: :bscf_core_invoices}
      t.references :virtual_account_transaction, null: true, foreign_key: {to_table: :bscf_core_virtual_account_transactions}
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :payment_method, null: false, default: 0
      t.datetime :payment_date 
      t.string :reference_number, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
