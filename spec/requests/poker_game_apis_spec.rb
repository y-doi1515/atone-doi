require 'rails_helper'

#エンベロープパターンを使用
RSpec.describe "Poker API", type: :request do

  describe "POST /api/v1/hand_rank_judge" do

    # 正常なリクエストのテスト
    context "with valid hands" do
      let(:params) { { cards: ["S1 S13 S12 S11 S10"] } }

      it "returns a 201 created status" do
        post "/api/v1/hand_rank_judge", params: params, as: :json
        # POST成功を示す :created (201) を期待する
        expect(response).to have_http_status(:created)
      end

      it "returns the correct rank name in the JSON body" do
        post "/api/v1/hand_rank_judge", params: params, as: :json
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["hand"]).to eq("ストレートフラッシュ")
      end
    end

    # 不正なカードが含まれるリクエストのテスト
    context "with invalid hand" do
      let(:params) { { cards: ["S1 S2 S3 S4 X99"] } }

      it "also returns a 201 created status" do
        post "/api/v1/hand_rank_judge", params: params, as: :json
        expect(response).to have_http_status(:created)
      end

      it "returns an msg message in the JSON body" do
        post "/api/v1/hand_rank_judge", params: params, as: :json
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to include("X99は正しく入力してください")
      end
    end

    context "with a mix of valid, invalid, and multiple hands" do
      let(:params) do
        {
          cards: [
            "C10 D10 H10 S10 D5", # フォー・オブ・ア・カインド (勝者)
            "H9 C9 S9 H1 C1",    # フルハウス
            "C7 C6 C5 C4 L10"    # L10が不正なカード
          ]
        }
      end

      it "returns a 201 status and a result list with successes and an msg" do
        post "/api/v1/hand_rank_judge", params: params, as: :json

        # 通信自体は成功している
        expect(response).to have_http_status(:created)

        # 返ってきたJSONをハッシュに直す
        json_response = JSON.parse(response.body)
        results = json_response["results"]

        # 3つの手札に対する結果が返ってきているか
        expect(results.length).to eq(3)

        # 1つ目の手札 (フォー・オブ・ア・カインド) の検証
        expect(results[0]["hand"]).to eq("フォー・オブ・ア・カインド")
        expect(results[0]["best"]).to be true
        expect(results[0]["msg"]).to be_nil

        # 2つ目の手札 (フルハウス) の検証
        expect(results[1]["hand"]).to eq("フルハウス")
        expect(results[1]["best"]).to be false
        expect(results[1]["msg"]).to be_nil

        # 3つ目の手札 (不正なカード) の検証
        expect(results[2]["best"]).to be false
        expect(results[2]["msg"]).to include("L10は正しく入力してください")
      end
    end

    context "when there is a tie for the winning hand" do
      let(:params) do
        {
          cards: [
            "S1 S13 S12 S4 S10", # フラッシュ
            "H5 D5 C5 S8 H8",    # フルハウス (勝者1)
            "H5 D5 C5 S8 H8",    # フルハウス (勝者2)
            "H1 D3 C4 S5 H8"     # ハイカード
          ]
        }
      end

      it "returns two winners" do
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        results = json_response["results"]

        expect(results.length).to eq(4)

        # 1人目 (ハイカード)
        expect(results[0]["hand"]).to eq("フラッシュ")
        expect(results[0]["best"]).to be false

        # 2人目 (フルハウス - 勝者)
        expect(results[1]["hand"]).to eq("フルハウス")
        expect(results[1]["best"]).to be true

        # 3人目 (フルハウス - 勝者)
        expect(results[2]["hand"]).to eq("フルハウス")
        expect(results[2]["best"]).to be true

        # 4人目 (ハイカード)
        expect(results[3]["hand"]).to eq("ハイカード")
        expect(results[3]["best"]).to be false
      end
    end

    context "with boundary values" do

      # --- 数字(ランク)の境界値テスト ---

      it "accepts the lowest rank (1) and the highest rank (13)" do
        # 1(エース)と13(キング)を含む正常な手札
        params = { cards: ["S1 H13 D12 C11 S10"] }
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to be_nil
      end

      it "rejects a rank of 0" do
        # 0は範囲外
        params = { cards: ["S0 H2 D3 C4 S5"] }
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to include("S0は正しく入力してください")
      end

      it "rejects a rank of 14" do
        # 14は範囲外
        params = { cards: ["S1 H2 D3 C4 D14"] }
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to include("D14は正しく入力してください")
      end

      # --- カード枚数の境界値テスト ---

      it "rejects a hand with 4 cards" do
        params = { cards: ["S1 H2 D3 C4"] }
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to include("5枚入力してください")
      end

      it "rejects a hand with 6 cards" do
        params = { cards: ["S1 H2 D3 C4 S5 D6"] }
        post "/api/v1/hand_rank_judge", params: params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["results"][0]["msg"]).to include("5枚入力してください")
      end
    end

  end
end