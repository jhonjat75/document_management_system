class AddDetailsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :role, :string
    add_column :users, :employee_id, :string
    add_column :users, :department, :string
    add_column :users, :position, :string
    add_column :users, :status, :string
    add_column :users, :start_date, :date
    add_column :users, :end_date, :date
    add_column :users, :phone, :string
    add_column :users, :address, :string
  end
end
