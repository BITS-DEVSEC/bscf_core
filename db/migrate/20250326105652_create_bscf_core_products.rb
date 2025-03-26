class CreateBscfCoreProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_products do |t|
      t.string :sku, null: false
      t.string :name, null: false
      t.string :description, null: false
      t.references :category, null: false, foreign_key: { to_table: :bscf_core_categories }
      t.decimal :base_price, null: false, default: 0.0

      t.timestamps
    end
    add_index :bscf_core_products, :sku, unique: true
  end
end
