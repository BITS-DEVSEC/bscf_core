class CreateBscfCoreInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_invoices do |t|
      t.references :order, null: false, foreign_key: { to_table: :bscf_core_orders }
      t.string :invoice_number, null: false, index: { unique: true }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :tax_amount, precision: 10, scale: 2, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.datetime :due_date
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
