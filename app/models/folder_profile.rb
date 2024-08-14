# frozen_string_literal: true

class FolderProfile < ApplicationRecord
  belongs_to :folder
  belongs_to :profile
end
