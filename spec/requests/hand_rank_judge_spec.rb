require 'rails_helper'

RSpec.describe "HandRankJudges", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/hand_rank_judge/index"
      expect(response).to have_http_status(:success)
    end
  end

end
