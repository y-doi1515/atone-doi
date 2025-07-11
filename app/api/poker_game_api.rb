# app/api/poker_game_api.rb

class PokerGameApi < Grape::API

  version 'v1', using: :path
  format :json

  resource :hand_rank_judge do
    desc 'ポーカーの役を判定する機能'
    params do
      requires :cards, type: Array[String], desc: '手札の文字列の配列'
    end

    post do
      results = [] #出力情報
      cards = params[:cards] #受け取る手札リスト
      #手札リストの中で強い手札の情報
      max_rank_hand_index = []
      max_rank_code = 9

      #手札ごとに判定
      cards.each_with_index do |card, index|
        rank_name = "" #役の強さ
        hand_list = card.to_s.split(" ") #柄と数字に分けてリスト化
        #入力チェック
        hand_check_service = HandCheckService.new(hand_list)
        error_msg = hand_check_service.validate
        #入力チェッククリア時
        if error_msg.nil?
          #手札の役を判定
          separated_cards = hand_check_service.separate_suit_rank
          rank_code = hand_check_service.judge_poker_hand(separated_cards)
          rank_name = hand_check_service.get_rank_name(rank_code)
          #結果を格納（後で勝者のbestを書き換える）
          results.push({ card: card, hand: rank_name, best: false})
          #暫定最強ハンド判定(引き分けの場合どちらもtrue)
          if rank_code < max_rank_code
            max_rank_code = rank_code
            max_rank_hand_index = [index]
          elsif rank_code == max_rank_code
            max_rank_hand_index.push(index)
          end
        #入力チェックがアウトの場合エラー文を返す
        else
          results.push({ card: card, hand: "", best: false, msg: error_msg })
        end
      end
      #勝者のbestを書き換え
      max_rank_hand_index.each do |index|
        results[index][:best] = true
      end

      { results: results }
    end
  end
end