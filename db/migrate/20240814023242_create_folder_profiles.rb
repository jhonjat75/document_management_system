class CreateFolderProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :folder_profiles do |t|
      t.references :folder, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
    end
  end
end
