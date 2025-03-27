class CreateBscfCoreQuotationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_quotation_items do |t|
      t.references :quotation, null: false, foreign_key: { to_table: :bscf_core_quotations }
      t.references :rfq_item, null: false, foreign_key: { to_table: :bscf_core_rfq_items }
      t.references :product, null: false, foreign_key: { to_table: :bscf_core_products }
      t.integer :quantity, null: false
      t.decimal :unit_price, null: false
      t.integer :unit, null: false
      t.decimal :subtotal, null: false

      t.timestamps
    end
  end
end
