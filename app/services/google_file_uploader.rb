# frozen_string_literal: true

class GoogleFileUploader
  GOOGLE_DRIVE_FOLDER_ID = ENV.fetch('GOOGLE_DRIVE_FOLDER_ID')
  Result = Struct.new(:file_id, :content_type)

  def self.upload(uploaded_file)
    return nil unless uploaded_file

    service = GoogleDriveService.new
    file_id = service.upload(
      file: uploaded_file,
      name: uploaded_file.original_filename,
      mime_type: uploaded_file.content_type,
      folder_id: GOOGLE_DRIVE_FOLDER_ID
    )
    service.share_publicly(file_id)

    Result.new(file_id, uploaded_file.content_type)
  end
end
