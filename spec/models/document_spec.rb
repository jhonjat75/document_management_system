# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'associations' do
    it { should belong_to(:folder) }
    it { should belong_to(:user).optional }
    it { should have_one_attached(:file) }
  end

  describe 'mount_uploader' do
    it 'mounts the file uploader' do
      expect(Document.new.file_path).to be_a(FileUploader)
    end
  end
end
