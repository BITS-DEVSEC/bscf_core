class CreateBscfCoreRequestForQuotations < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_request_for_quotations do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
