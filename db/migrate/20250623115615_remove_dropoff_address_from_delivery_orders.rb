class RemoveDropoffAddressFromDeliveryOrders < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :bscf_core_delivery_orders, column: :dropoff_address_id
    remove_index :bscf_core_delivery_orders, :dropoff_address_id
    remove_column :bscf_core_delivery_orders, :dropoff_address_id
  end
end
