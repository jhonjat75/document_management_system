# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  enum role: { super_admin: 0, admin: 1, driver: 2 }
  def fullname
    "#{first_name} #{last_name}"
  end
end
