class CreateBscfCoreUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_user_profiles do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.date :date_of_birth, null: false
      t.string :nationality, null: false
      t.string :occupation, null: false
      t.string :source_of_funds, null: false
      t.integer :kyc_status, default: 0
      t.integer :gender, null: false
      t.datetime :verified_at
      t.references :verified_by, null: true, foreign_key: { to_table: :bscf_core_users }
      t.references :address, null: false, foreign_key: { to_table: :bscf_core_addresses }
      t.string :fayda_id

      t.timestamps
    end
  end
end
