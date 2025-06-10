class UpdateDeliveryTables < ActiveRecord::Migration[8.0]
  def up
    remove_column :bscf_core_delivery_orders, :buyer_phone
    remove_column :bscf_core_delivery_orders, :seller_phone
    
    add_column :bscf_core_delivery_orders, :estimated_delivery_price, :float
    
    rename_column :bscf_core_delivery_orders, :delivery_price, :actual_delivery_price

    add_reference :bscf_core_delivery_order_items, :pickup_address, foreign_key: { to_table: :bscf_core_addresses }
    add_reference :bscf_core_delivery_order_items, :dropoff_address, foreign_key: { to_table: :bscf_core_addresses }
    
    remove_reference :bscf_core_delivery_order_items, :product
  end
end
