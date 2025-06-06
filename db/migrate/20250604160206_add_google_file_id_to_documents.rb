class AddGoogleFileIdToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :google_file_id, :string
  end
end
