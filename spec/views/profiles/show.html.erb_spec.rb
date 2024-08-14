# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'profiles/show', type: :view do
  before(:each) do
    @profile = assign(:profile, Profile.create!(
                                  name: 'Name',
                                  description: 'MyText'
                                ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
  end
end
