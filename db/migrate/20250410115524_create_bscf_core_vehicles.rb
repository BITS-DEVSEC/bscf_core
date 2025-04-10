class CreateBscfCoreVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_vehicles do |t|
      t.references :driver, foreign_key: { to_table: :bscf_core_users }, null: true
      t.string :plate_number, null: false
      t.string :vehicle_type, null: false
      t.string :brand, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.string :color, null: false

      t.timestamps
    end

    add_index :bscf_core_vehicles, :plate_number, unique: true
  end
end
