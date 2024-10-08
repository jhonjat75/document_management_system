# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: true
  has_many :user_profiles
  has_many :profiles, through: :user_profiles
  after_create :assign_default_profiles

  enum role: { admin: 1, general: 2 }
  def fullname
    "#{first_name} #{last_name}"
  end

  def assign_default_profiles
    Profile.find_each do |profile|
      UserProfile.create(
        user: self,
        profile: profile,
        can_create: false,
        can_read: false,
        can_update: false,
        can_delete: false
      )
    end
  end
end
