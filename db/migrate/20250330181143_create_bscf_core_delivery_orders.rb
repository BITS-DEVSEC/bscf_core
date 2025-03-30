class CreateBscfCoreDeliveryOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_delivery_orders do |t|
      t.references :order, null: false, foreign_key: {to_table: :bscf_core_orders, on_delete: :cascade, on_update: :cascade}
      t.references :delivery_address, null: false, foreign_key: {to_table: :bscf_core_addresses}
      t.string :contact_phone, null: false
      t.text :delivery_notes
      t.datetime :estimated_delivery_time, null: false
      t.datetime :delivery_start_time
      t.datetime :delivery_end_time
      t.integer :status, null: false

      t.timestamps
    end
  end
end
