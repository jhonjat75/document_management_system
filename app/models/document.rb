# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :folder
  belongs_to :user, optional: true

  def file_extension
    GOOGLE_DRIVE_FILE_EXTENSIONS[content_type] || content_type
  end
end
