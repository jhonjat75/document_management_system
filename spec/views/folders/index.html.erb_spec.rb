# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'folders/index', type: :view do
  before(:each) do
    assign(:folders, [
             Folder.create!(
               name: 'Name',
               description: 'Description',
               user: nil,
               parent_folder: nil
             ),
             Folder.create!(
               name: 'Name',
               description: 'Description',
               user: nil,
               parent_folder: nil
             )
           ])
  end

  it 'renders a list of folders' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Description'.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
