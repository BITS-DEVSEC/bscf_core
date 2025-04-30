class AddActualDeliveryTimeToDeliveryOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_delivery_orders, :actual_delivery_time, :datetime
  end
end
