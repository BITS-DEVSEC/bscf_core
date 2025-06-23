class AddDropOffAdressToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_orders, :drop_off_address_id, :bigint
    add_foreign_key :bscf_core_orders, :bscf_core_addresses, column: :drop_off_address_id
    change_column_null :bscf_core_orders, :drop_off_address_id, true
    add_index :bscf_core_orders, :drop_off_address_id, name: "a_on_bscf_core_ord_index"
  end
end
