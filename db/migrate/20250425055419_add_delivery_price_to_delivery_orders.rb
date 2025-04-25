class AddDeliveryPriceToDeliveryOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_delivery_orders, :delivery_price, :float
  end
end
