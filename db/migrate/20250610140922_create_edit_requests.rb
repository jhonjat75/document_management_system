class CreateEditRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :edit_requests do |t|
      t.text :reason
      t.string :status, default: "pending"
      t.references :user, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
