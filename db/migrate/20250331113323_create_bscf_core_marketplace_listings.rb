class CreateBscfCoreMarketplaceListings < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_marketplace_listings do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.integer :listing_type, null: false
      t.integer :status, null: false
      t.boolean :allow_partial_match, null: false, default: false
      t.datetime :preferred_delivery_date
      t.datetime :expires_at
      t.boolean :is_active, default: true
      t.references :address, null: false, foreign_key: { to_table: :bscf_core_addresses }

      t.timestamps
    end
  end
end
