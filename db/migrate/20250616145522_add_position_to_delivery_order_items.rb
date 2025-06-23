class AddPositionToDeliveryOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_delivery_order_items, :position, :integer
    add_index :bscf_core_delivery_order_items, :position
  end
end
