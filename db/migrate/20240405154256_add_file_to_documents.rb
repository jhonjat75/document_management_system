class AddFileToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :file, :string
  end
end
