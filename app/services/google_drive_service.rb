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
    uploaded_file = @drive_service.create_file(
      metadata,
      upload_source: file.tempfile,
      content_type: mime_type,
      fields: 'id'
    )
    uploaded_file.id
  end

  def share_publicly(file_id)
    permission = Google::Apis::DriveV3::Permission.new(
      type: 'anyone',
      role: 'reader'
    )
    @drive_service.create_permission(file_id, permission)
  end

  private

  attr_reader :authorizer

  def build_metadata(name, folder_id)
    {
      name: name,
      parents: [folder_id]
    }
  end

  def create_permission(file_id, permission)
    @drive_service.create_permission(file_id, permission)
  end
end
