class AddContentTypeToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :content_type, :string
  end
end
