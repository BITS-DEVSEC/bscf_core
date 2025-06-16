class UpdateAddressCoordinatesType < ActiveRecord::Migration[8.0]
  def change
    change_column :bscf_core_addresses, :latitude, :decimal, precision: 10, scale: 6, using: 'latitude::numeric(10,6)'
    change_column :bscf_core_addresses, :longitude, :decimal, precision: 10, scale: 6, using: 'longitude::numeric(10,6)'
   end
end
