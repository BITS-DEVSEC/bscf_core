class CreateBscfCoreOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_order_items do |t|
      t.references :order, null: false, foreign_key: { to_table: :bscf_core_orders }
      t.references :product, null: false, foreign_key: { to_table: :bscf_core_products }
      t.references :quotation_item, null: true, foreign_key: { to_table: :bscf_core_quotation_items }
      t.float :quantity, null: false
      t.float :unit_price, null: false
      t.float :subtotal, null: false

      t.timestamps
    end
  end
end
