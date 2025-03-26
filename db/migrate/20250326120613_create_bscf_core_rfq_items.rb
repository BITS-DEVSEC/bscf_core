class CreateBscfCoreRfqItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_rfq_items do |t|
      t.references :request_for_quotation, null: false, foreign_key: {to_table: :bscf_core_request_for_quotations}
      t.references :product, null: false, foreign_key: {to_table: :bscf_core_products}
      t.float :quantity, null: false
      t.text :notes

      t.timestamps
    end
  end
end
