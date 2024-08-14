# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'profiles/index', type: :view do
  before(:each) do
    assign(:profiles, [
             Profile.create!(
               name: 'Name',
               description: 'MyText'
             ),
             Profile.create!(
               name: 'Name',
               description: 'MyText'
             )
           ])
  end

  it 'renders a list of profiles' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
  end
end
