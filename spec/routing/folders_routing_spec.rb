# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FoldersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/folders').to route_to('folders#index')
    end

    it 'routes to #new' do
      expect(get: '/folders/new').to route_to('folders#new')
    end

    it 'routes to #show' do
      expect(get: '/folders/1').to route_to('folders#show', id: '1')
    end
  end
end
