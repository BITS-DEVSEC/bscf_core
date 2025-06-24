class AddDocumentTypeToBusinessDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_business_documents, :document_type, :integer
  end
end
