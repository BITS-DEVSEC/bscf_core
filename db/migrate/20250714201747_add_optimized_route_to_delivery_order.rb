class AddOptimizedRouteToDeliveryOrder < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_delivery_orders, :optimized_route, :jsonb
  end
end
