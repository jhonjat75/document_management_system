class AddUserIdToFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :folders, :user_id, :integer
    add_index :folders, :user_id
  end
end
