require 'rails_helper'

RSpec.describe "HandsDeals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/hands_deal/index"
      expect(response).to have_http_status(:success)
    end
  end

end
