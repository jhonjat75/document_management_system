# frozen_string_literal: true

class FolderService
  def initialize(folder = nil)
    @folder = folder
  end

  def save
    @folder.save
  end

  def update(attributes)
    @folder.update(attributes)
  end

  def destroy
    @folder.destroy
  end

  def self.find(id)
    Folder.find(id)
  end

  def self.new_instance(attributes = {})
    Folder.new(attributes)
  end

  def self.create(attributes, user_id = nil)
    folder = new_instance(attributes)
    folder.user_id = user_id if user_id
    new(folder).save
    folder
  end

  def self.parent_folders
    Folder.where(parent_folder_id: nil)
  end
end
