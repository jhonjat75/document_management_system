# frozen_string_literal: true

class Folder < ApplicationRecord
  belongs_to :user
  has_many :subfolders, class_name: 'Folder', foreign_key: 'parent_folder_id', dependent: :destroy
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  has_many :documents, dependent: :destroy
end
