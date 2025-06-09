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

  enum role: { general: 2, admin: 1 }
  def fullname
    "#{first_name} #{last_name}"
  end

  def can_update_folder?(folder)
    return true if role == 'admin'

    permission_on_folder?(folder, :can_update)
  end

  def can_create_folder?(folder)
    return true if role == 'admin'

    permission_on_folder?(folder, :can_create)
  end

  def can_delete_folder?(folder)
    return true if role == 'admin'

    permission_on_folder?(folder, :can_delete)
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

  private

  def permission_on_folder?(folder, permission)
    profile_ids = user_profiles.where(permission => true).pluck(:profile_id)
    folder_profile_ids = folder.folder_profiles.pluck(:profile_id)
    (profile_ids & folder_profile_ids).any?
  end
end
