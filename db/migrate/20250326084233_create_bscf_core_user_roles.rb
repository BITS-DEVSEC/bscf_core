class CreateBscfCoreUserRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_user_roles do |t|
      t.references :user, null: false, foreign_key: { to_table: :bscf_core_users }
      t.references :role, null: false, foreign_key: { to_table: :bscf_core_roles }

      t.timestamps
    end
  end
end
