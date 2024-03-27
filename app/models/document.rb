# frozen_string_literal: true

class Document < ApplicationRecord
  mount_uploader :file_path, FileUploader
  belongs_to :folder
  belongs_to :user, optional: true
  has_one_attached :file
end
