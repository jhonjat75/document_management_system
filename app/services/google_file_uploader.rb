# frozen_string_literal: true

class GoogleFileUploader
  GOOGLE_DRIVE_FOLDER_ID = ENV.fetch('GOOGLE_DRIVE_FOLDER_ID').freeze
  Result = Struct.new(:file_id, :content_type)

  def self.upload(uploaded_file:, user:, folder:)
    return nil unless uploaded_file

    service = GoogleDriveService.new

    file_id = upload_file_to_drive(uploaded_file, service)
    share_file_with_user(file_id, user, service, folder)

    Result.new(file_id, uploaded_file.content_type)
  end

  def self.upload_file_to_drive(file, service)
    service.upload(
      file: file,
      name: file.original_filename,
      mime_type: file.content_type,
      folder_id: GOOGLE_DRIVE_FOLDER_ID
    )
  end

  def self.share_file_with_user(file_id, user, service, folder)
    service.share_with_user(
      file_id: file_id,
      email: user.email,
      role: user.can_update_folder?(folder) ? 'writer' : 'reader'
    )
  end

  private_class_method :upload_file_to_drive, :share_file_with_user
end
