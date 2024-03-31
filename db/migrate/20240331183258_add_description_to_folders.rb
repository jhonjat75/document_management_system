class AddDescriptionToFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :folders, :description, :text
  end
end
