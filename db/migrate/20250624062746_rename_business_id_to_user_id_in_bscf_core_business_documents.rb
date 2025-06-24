class RenameBusinessIdToUserIdInBscfCoreBusinessDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :bscf_core_business_documents, column: :business_id
    rename_column :bscf_core_business_documents, :business_id, :user_id
    add_foreign_key :bscf_core_business_documents, :bscf_core_users, column: :user_id
  end
end
