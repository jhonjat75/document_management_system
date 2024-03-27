class AddNameToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :name, :string
  end
end
