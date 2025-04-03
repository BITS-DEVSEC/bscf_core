class CreateBscfCoreWholesalerProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_wholesaler_products do |t|
      t.references :business, null: false, foreign_key: { to_table: :bscf_core_businesses }
      t.references :product, null: false, foreign_key: { to_table: :bscf_core_products }
      t.integer :minimum_order_quantity, null: false, default: 1
      t.decimal :wholesale_price
      t.integer :available_quantity, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
