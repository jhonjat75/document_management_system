# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'googleauth'

class GoogleDriveService
  SCOPE = ['https://www.googleapis.com/auth/drive'].freeze

  def initialize
    json_key_io = File.open(ENV.fetch('GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON'))
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json_key_io,
      scope: SCOPE
    )

    # Intentar primero sin impersonation (más común para Shared Drives)
    # Solo usar impersonation si es explícitamente necesario
    # El service account puede tener acceso directo a Shared Drives
    if ENV['GOOGLE_DRIVE_IMPERSONATE_USER'].present?
      begin
        authorizer.sub = ENV['GOOGLE_DRIVE_IMPERSONATE_USER']
        authorizer.fetch_access_token!
      rescue Signet::AuthorizationError
        # Si falla con impersonation, intentar sin impersonation
        Rails.logger.warn 'Domain-wide delegation falló, intentando sin impersonation'
        authorizer.sub = nil
        authorizer.fetch_access_token!
      end
    else
      authorizer.fetch_access_token!
    end

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = authorizer
    @authorizer = authorizer
  end

  def upload(file:, name:, mime_type:, folder_id:)
    metadata = build_metadata(name, folder_id)
    uploaded_file = @drive_service.create_file(
      metadata,
      upload_source: file.tempfile,
      content_type: mime_type,
      fields: 'id',
      supports_all_drives: true
    )
    uploaded_file.id
  end

  def delete_file(file_id)
    @drive_service.delete_file(file_id, supports_all_drives: true)
  end

  def share_publicly(file_id)
    permission = Google::Apis::DriveV3::Permission.new(
      type: 'anyone',
      role: 'reader'
    )
    @drive_service.create_permission(file_id, permission, supports_all_drives: true)
  end

  def get_file_content(file_id)
    content = StringIO.new
    @drive_service.get_file(
      file_id,
      download_dest: content,
      supports_all_drives: true,
      include_items_from_all_drives: true
    )
    content.rewind
    content
  end

  def export_file(file_id, mime_type)
    content = StringIO.new
    @drive_service.export_file(
      file_id,
      mime_type,
      download_dest: content,
      supports_all_drives: true,
      include_items_from_all_drives: true
    )
    content.rewind
    content
  end

  def get_file_metadata(file_id)
    @drive_service.get_file(
      file_id,
      fields: 'id,name,mimeType,size,createdTime,modifiedTime,parents',
      supports_all_drives: true
    )
  end

  def list_files_in_folder(folder_id)
    files = []
    page_token = nil

    loop do
      result = @drive_service.list_files(
        q: "'#{folder_id}' in parents and trashed=false",
        fields: 'nextPageToken, files(id, name, mimeType, size, createdTime)',
        page_size: 100,
        page_token: page_token,
        supports_all_drives: true,
        include_items_from_all_drives: true
      )

      files.concat(result.files || [])
      page_token = result.next_page_token
      break if page_token.nil?
    end

    files
  end

  def copy_file_to_folder(file_id, destination_folder_id, new_name: nil)
    file_metadata = Google::Apis::DriveV3::File.new
    file_metadata.parents = [destination_folder_id]
    file_metadata.name = new_name if new_name

    copied_file = @drive_service.copy_file(
      file_id,
      file_metadata,
      fields: 'id',
      supports_all_drives: true
    )
    copied_file.id
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
    @drive_service.create_permission(file_id, permission, supports_all_drives: true)
  end
end
