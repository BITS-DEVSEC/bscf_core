class UpdateNotNullConstraintsInBusinesses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bscf_core_user_profiles, :source_of_funds, false
    change_column_null :bscf_core_user_profiles, :occupation, false
    change_column_null :bscf_core_businesses, :tin_number, false
  end
end
