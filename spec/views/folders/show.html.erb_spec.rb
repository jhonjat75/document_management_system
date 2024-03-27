# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'folders/show', type: :view do
  before(:each) do
    @folder = assign(:folder, Folder.create!(
                                name: 'Name',
                                description: 'Description',
                                user: nil,
                                parent_folder: nil
                              ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
