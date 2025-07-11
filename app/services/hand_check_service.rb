class HandCheckService
  def initialize(cards)
    @cards = cards
  end

  #カードを柄と数字に分けて新たなリストで返す
  def separate_suit_rank
    separated_suit_rank_cards = []
    @cards.each do |card|
      suit_rank_pair = [card[0],card[1..].to_i]
      separated_suit_rank_cards.push(suit_rank_pair)
    end
    return separated_suit_rank_cards
  end

  #受け取ったカードから役を判定
  def judge_poker_hand(separated_suit_rank_cards)

    #数字、柄のみの配列をそれぞれ作成
    rank_only_list = []
    suit_only_list = []
    separated_suit_rank_cards.each do |card_pair|
      rank_only_list.push(card_pair[1..])
      suit_only_list.push(card_pair[0])
    end
    #各数字の出現回数をハッシュとしてカウント
    duplicate_count_list = rank_only_list.tally
    #数字の出現回数を昇順に並べ替えリスト化
    duplicate_num_sorted_num = duplicate_count_list.values.sort.reverse

    #数字の昇順に配列を並べ替え
    sorted_cards = separated_suit_rank_cards.sort_by { |card| card[1] }
    #ストレートフラッシュ判定
    base_suit = sorted_cards[0][0] #判定の基準となる柄
    base_rank = sorted_cards[0][1] #判定の基準となる数字
    loop_count = 0
    sorted_cards.each do |card|
      #(H1 H13 H12 H11 H10)のようなパターンの処理(二周目判定)
      if base_rank == 2 && card[1] == 10
        base_rank = 10
      end
      if base_rank == card[1] && base_suit == card[0]
        loop_count += 1
        base_rank += 1 #次の数字が連続した数字かを判定する変数
      else
        break
      end
    end
    if loop_count == 5
      return 1
    end

    #フォー・オブ・ア・カインド
    if duplicate_count_list.max_by{ |_value, count| count }[1] == 4
      return 2
    end

    #フルハウス
    if duplicate_count_list.max_by{ |_value, count| count }[1] == 3
      #２番目に多い重複数が２かを判定
      if duplicate_num_sorted_num[1] == 2
        return 3
      end
    end

    #フラッシュ
    #重複を排除し、一つにまとまるかを判定
    if suit_only_list.uniq.size == 1
      return 4
    end

    #ストレート
    base_rank = sorted_cards[0][1] #判定の基準となる数字
    loop_count = 0
    sorted_cards.each do |card|
      #(H1 H13 H12 H11 H10)のようなパターンの処理(二周目判定)
      if base_rank == 2 && card[1] == 10
        base_rank = 10
      end
      if base_rank == card[1]
        loop_count += 1
        base_rank += 1 #次の数字が連続した数字かを判定する変数
      else
        break
      end
    end
    if loop_count == 5
      return 5
    end

    #スリー・オブ・ア・カインド
    if duplicate_count_list.max_by{ |_value, count| count }[1] == 3
      return 6
    end

    #ツーペア/ワンペア
    if duplicate_num_sorted_num[0] == 2
      #２番目に多い重複数が２かを判定
      if duplicate_num_sorted_num[1] == 2
        return 7
      else
        return 8
      end
    end

    return 9

  end

  def get_rank_name(rank_code)
    case rank_code
    when 1
      return "ストレートフラッシュ"
    when 2
      return "フォー・オブ・ア・カインド"
    when 3
      return "フルハウス"
    when 4
      return "フラッシュ"
    when 5
      return "ストレート"
    when 6
      return "スリー・オブ・ア・カインド"
    when 7
      return "ツーペア"
    when 8
      return "ワンペア"
    when 9
      return "ハイカード"
    end
  end

  def validate

    error_msg = []
    suit_list = ["H","C","S","D"]
    #手札が五枚ないときの処理
    if @cards.length != 5
      error_msg.push("5枚入力してください")
    end
    @cards.each do |card|
      #値が正しく入力されているのかの判定
      unless suit_list.include?(card[0]) and (card[1..].to_i > 0 && card[1..].to_i < 14) and card[1..].match?(/\A\d+\z/)
        error_msg.push(card + "は正しく入力してください")
      end
    end
    #重複をリスト化
    duplicate_count_list = @cards.tally
    #重複があるかの判定
    duplicate_count_list.each do |card,count|
      if count > 1
        error_msg.push(card + "は重複しています")
      end
    end
    if error_msg.empty?
      error_msg = nil
    end
    return error_msg
  end


end