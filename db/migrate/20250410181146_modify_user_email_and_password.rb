class ModifyUserEmailAndPassword < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bscf_core_users, :email, true
    change_column :bscf_core_users, :password_digest, :string, limit: 60, null: false
  end
end
