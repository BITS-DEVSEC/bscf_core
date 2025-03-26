class CreateBscfCoreCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_categories do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.bigint :parent_id

      t.timestamps
    end
  end
end
