# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:subfolders).class_name('Folder').with_foreign_key('parent_folder_id').dependent(:destroy) }
    it { should belong_to(:parent_folder).class_name('Folder').optional }
    it { should have_many(:documents).dependent(:destroy) }
  end
end
