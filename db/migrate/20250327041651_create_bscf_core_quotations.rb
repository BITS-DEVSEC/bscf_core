class CreateBscfCoreQuotations < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_quotations do |t|
      t.references :request_for_quotation, null: false, foreign_key: { to_table: :bscf_core_request_for_quotations }
      t.references :business, null: false, foreign_key: { to_table: :bscf_core_businesses }
      t.decimal :price, null: false
      t.date :delivery_date, null: false
      t.datetime :valid_until, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
