# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'profiles/edit', type: :view do
  before(:each) do
    @profile = assign(:profile, Profile.create!(
                                  name: 'MyString',
                                  description: 'MyText'
                                ))
  end

  it 'renders the edit profile form' do
    render

    assert_select 'form[action=?][method=?]', profile_path(@profile), 'post' do
      assert_select 'input[name=?]', 'profile[name]'

      assert_select 'textarea[name=?]', 'profile[description]'
    end
  end
end
