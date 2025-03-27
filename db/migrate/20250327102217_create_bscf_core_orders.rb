class CreateBscfCoreOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_orders do |t|
      t.references :ordered_by, null: true, foreign_key: {to_table: :bscf_core_users}
      t.references :ordered_to, null: true, foreign_key: {to_table: :bscf_core_users}
      t.references :quotation, null: true, foreign_key: {to_table: :bscf_core_quotations}
      t.integer :order_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.float :total_amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
