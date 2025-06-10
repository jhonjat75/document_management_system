# frozen_string_literal: true

class GoogleDrivePermissionService
  def initialize(document)
    @document = document
    @drive = GoogleDriveService.new
  end

  def grant_edit_access(email)
    permission = Google::Apis::DriveV3::Permission.new(
      type: 'user',
      role: 'writer',
      email_address: email
    )
    @drive.send(:create_permission, @document.google_file_id, permission)
  end
end
