# frozen_string_literal: true

class Profile < ApplicationRecord
  has_many :user_profiles
  has_many :users, through: :user_profiles
  has_many :folder_profiles
  has_many :folders, through: :folder_profiles

  after_create :assign_to_all_users

  private

  def assign_to_all_users
    User.find_each do |user|
      UserProfile.create(user: user, profile: self, can_create: false, can_read: false, can_update: false,
                         can_delete: false)
    end
  end
end
