class RemoveOrderIdFromDeliveryOrdersAndAddDeliveryOrderIdToOrders < ActiveRecord::Migration[8.0]
  def change
    remove_reference :bscf_core_delivery_orders, :order, foreign_key: { to_table: :bscf_core_orders }, index: true
    add_reference :bscf_core_orders, :delivery_order, foreign_key: { to_table: :bscf_core_delivery_orders }, index: true, null: true
  end
end
