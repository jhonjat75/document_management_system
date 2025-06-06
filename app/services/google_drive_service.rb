# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'googleauth'

class GoogleDriveService
  SCOPE = ['https://www.googleapis.com/auth/drive'].freeze

  def initialize
    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV.fetch('GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON')),
      scope: SCOPE
    )
    @authorizer.fetch_access_token!

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = authorizer
  end

  def upload(file:, name:, mime_type:, folder_id:)
    metadata = build_metadata(name, folder_id)

    uploaded = @drive_service.create_file(
      metadata,
      upload_source: file.tempfile,
      content_type: mime_type,
      fields: 'id'
    )

    uploaded.id
  end

  def delete_file(file_id)
    @drive_service.delete_file(file_id)
  end

  def share_with_user(file_id:, email:, role: 'reader')
    permission = Google::Apis::DriveV3::Permission.new(
      type: 'user',
      role: role, # 'reader' o 'writer'
      email_address: email
    )

    @drive_service.create_permission(file_id, permission)
  end

  def update_permission(file_id:, email:, role: 'reader')
    permission_id = permission_id_for(file_id, email)
    return if permission_id.nil?

    permission = build_permission(email, role)

    apply_updated_permission(file_id, permission_id, permission)
  end

  private

  attr_reader :authorizer

  def permission_id_for(file_id, email)
    list = @drive_service.list_permissions(
      file_id,
      fields: 'permissions(id,emailAddress)'
    )

    match = list.permissions.find { |p| p.email_address == email }
    match&.id
  end

  def build_metadata(name, folder_id)
    {
      name: name,
      parents: [folder_id]
    }
  end

  def build_permission(email, role)
    {
      role: role,
      type: 'user',
      email_address: email
    }
  end

  def apply_updated_permission(file_id, permission_id, permission)
    @drive_service.update_permission(
      file_id,
      permission_id,
      permission,
      fields: 'id'
    )
  end
end
