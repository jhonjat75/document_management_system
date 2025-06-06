# frozen_string_literal: true

class PermissionSyncService
  def self.sync_google_drive_permissions(user_profile)
    user = user_profile.user
    documents = documents_linked_to_profile(user_profile.profile_id)

    documents.each do |document|
      next unless document.google_file_id.present?

      role = user.can_update_folder?(document.folder) ? 'writer' : 'reader'

      GoogleDriveService.new.update_permission(
        file_id: document.google_file_id,
        email: user.email,
        role: role
      )
    end
  end

  def self.documents_linked_to_profile(profile_id)
    folder_ids = FolderProfile
                   .where(profile_id: profile_id)
                   .pluck(:folder_id)

    Document.where(folder_id: folder_ids)
  end
end
