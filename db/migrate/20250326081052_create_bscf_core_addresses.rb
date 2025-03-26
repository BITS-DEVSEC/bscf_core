class CreateBscfCoreAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_addresses do |t|
      t.string :city
      t.string :sub_city
      t.string :woreda
      t.string :latitude
      t.string :longitude
      t.string :house_number

      t.timestamps
    end
  end
end
