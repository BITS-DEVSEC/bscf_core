class AddProductToMarketPlaceListings < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_marketplace_listings, :product_id, :bigint
    add_column :bscf_core_marketplace_listings, :price, :float
    change_column_null :bscf_core_marketplace_listings, :product_id, false
    add_foreign_key :bscf_core_marketplace_listings, :bscf_core_products, column: :product_id
    add_index :bscf_core_marketplace_listings, :product_id, name: "p_on_bscf_core_mpl_index"
  end
end
