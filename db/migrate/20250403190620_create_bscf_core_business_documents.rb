class CreateBscfCoreBusinessDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_business_documents do |t|
      t.references :business, null: false, foreign_key: { to_table: :bscf_core_businesses }
      t.string :document_number, null: false
      t.string :document_name, null: false
      t.string :document_description
      t.datetime :verified_at
      t.boolean :is_verified, null: false, default: false

      t.timestamps
    end
  end
end
