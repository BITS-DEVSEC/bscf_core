class CreateBscfCoreUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :bscf_core_users do |t|
      t.string :first_name, null: false
      t.string :middle_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :password_digest, null: false

      t.index :email, unique: true
      t.index :phone_number, unique: true


      t.timestamps
    end
  end
end
