class AddDeliveryDetailsToDeliveryOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :bscf_core_delivery_orders, :driver, foreign_key: { to_table: :bscf_core_users }
    add_reference :bscf_core_delivery_orders, :pickup_address, null: false, foreign_key: { to_table: :bscf_core_addresses }
    add_column :bscf_core_delivery_orders, :buyer_phone, :string, null: false
    add_column :bscf_core_delivery_orders, :seller_phone, :string, null: false
    rename_column :bscf_core_delivery_orders, :delivery_address_id, :dropoff_address_id
    rename_column :bscf_core_delivery_orders, :contact_phone, :driver_phone
  end
end
