class CreateUserProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.boolean :can_create
      t.boolean :can_read
      t.boolean :can_update
      t.boolean :can_delete

      t.timestamps
    end
  end
end
