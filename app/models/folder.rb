# frozen_string_literal: true

class Folder < ApplicationRecord
  belongs_to :user
  has_many :subfolders, class_name: 'Folder', foreign_key: 'parent_folder_id', dependent: :destroy
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  has_many :documents, dependent: :destroy

  has_many :folder_profiles, dependent: :destroy
  has_many :profiles, through: :folder_profiles

  accepts_nested_attributes_for :folder_profiles, allow_destroy: true
  after_update :update_subfolders_profiles

  private

  def update_subfolders_profiles
    subfolders.each do |subfolder|
      subfolder.update(profile_ids: profile_ids)
    end
  end
end
