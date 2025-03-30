class CreateBscfCoreDeliveryOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_delivery_order_items do |t|
      t.references :delivery_order, null: false, foreign_key: { to_table: :bscf_core_delivery_orders }
      t.references :order_item, null: false, foreign_key: { to_table: :bscf_core_order_items }
      t.references :product, null: false, foreign_key: { to_table: :bscf_core_products }
      t.integer :quantity, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
