class CreateBscfCoreBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_businesses do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.string :business_name, null: false
      t.string :tin_number, null: false
      t.integer :business_type, null: false, default: 0
      t.datetime :verified_at
      t.integer :verification_status, null: false, default: 0

      t.timestamps
    end
  end
end
