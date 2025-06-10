require 'rails_helper'

RSpec.describe "EditRequests", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/edit_requests/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/edit_requests/create"
      expect(response).to have_http_status(:success)
    end
  end

end
