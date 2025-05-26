class CreateBscfCoreVouchers < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_vouchers do |t|
      t.string :full_name, null: false
      t.string :phone_number, null: false
      t.decimal :amount, null: false
      t.string :reason
      t.string :code, null: false
      t.integer :status, null: false, default: 0
      t.datetime :expires_at
      t.references :issued_by, null: false, foreign_key: {to_table: :bscf_core_users}
      t.datetime :redeemed_at
      t.datetime :returned_at

      t.timestamps
    end
    add_index :bscf_core_vouchers, :code
  end
end
