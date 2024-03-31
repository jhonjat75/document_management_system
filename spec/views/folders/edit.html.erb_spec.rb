# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'folders/edit', type: :view do
  before(:each) do
    @folder = assign(:folder, Folder.create!(
                                name: 'MyString',
                                description: 'MyString',
                                user: nil,
                                parent_folder: nil
                              ))
  end

  it 'renders the edit folder form' do
    render

    assert_select 'form[action=?][method=?]', folder_path(@folder), 'post' do
      assert_select 'input[name=?]', 'folder[name]'

      assert_select 'input[name=?]', 'folder[description]'

      assert_select 'input[name=?]', 'folder[user_id]'

      assert_select 'input[name=?]', 'folder[parent_folder_id]'
    end
  end
end
