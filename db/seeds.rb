# frozen_string_literal: true

User.create!(
  email: 'superadmin@example.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Super',
  last_name: 'Admin',
  role: 0
)

User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Admin',
  last_name: 'User',
  role: 1
)

User.create!(
  email: 'driver@example.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Driver',
  last_name: 'User',
  role: 2
)
