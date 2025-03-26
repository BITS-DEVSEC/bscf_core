class CreateBscfCoreRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_roles do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
