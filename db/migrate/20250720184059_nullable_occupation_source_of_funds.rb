class NullableOccupationSourceOfFunds < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bscf_core_user_profiles, :occupation, true
    change_column_null :bscf_core_user_profiles, :source_of_funds, true
  end
end
