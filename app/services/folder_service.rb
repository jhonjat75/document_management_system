# frozen_string_literal: true

class FolderService
  def initialize(folder = nil)
    @folder = folder
  end

  def save
    @folder.save
  end

  def update(attributes)
    @folder.update(attributes)
  end

  def destroy
    @folder.destroy
  end

  def self.find(id)
    Folder.find(id)
  end

  def self.new_instance(attributes = {})
    Folder.new(attributes)
  end

  def self.create(attributes, user_id = nil)
    folder = new_instance(attributes)
    folder.user_id = user_id if user_id
    new(folder).save
    folder
  end

  def self.parent_folders(user)
    if user.admin?
      folders = Folder.where(parent_folder_id: nil)
      folders.map { |folder| { folder: folder, can_edit: true, can_delete: true } }
    else
      folders_with_read_permission(user)
    end
  end

  def self.folders_with_read_permission(user)
    profile_ids = user.user_profiles.where(can_read: true).pluck(:profile_id)
    folders = Folder.joins(:folder_profiles)
                    .where(parent_folder_id: nil, folder_profiles: { profile_id: profile_ids }).distinct

    folders.map do |folder|
      user_profile = UserProfile.find_by(user: user, profile: folder.profile_ids.first)
      {
        folder: folder, can_edit: user_profile&.can_update || false,
        can_delete: user_profile&.can_delete || false
      }
    end
  end
end
