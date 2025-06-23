class CreateBscfCoreInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_invoice_items do |t|
      t.references :invoice, null: false, foreign_key: { to_table: :bscf_core_invoices }
      t.references :order_item, null: false, foreign_key: { to_table: :bscf_core_order_items }
      t.string :description
      t.integer :quantity, null: false
      t.decimal :unit_price, null: false, precision: 10, scale: 2
      t.decimal :tax_rate, precision: 10, scale: 2
      t.decimal :tax_amount, precision: 10, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2
      t.decimal :subtotal, null: false, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
