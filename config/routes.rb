# config/routes.rb
Rails.application.routes.draw do
  # Webページ表示用のルート
  root 'hand_rank_judge#index'

  # Grape APIを /api パスに接続
  mount PokerGameApi => '/api'
end