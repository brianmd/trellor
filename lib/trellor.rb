# TODO: show card descriptions

require_relative "trellor/version"
require 'trello'

module Trellor
  class Trellor
    def client(key=ENV['TRELLOR_KEY'], token=ENV['TRELLOR_TOKEN'])
      @client ||= connect(key, token)
    end

    def connect(key=ENV['TRELLOR_KEY'], token=ENV['TRELLOR_TOKEN'])
      Trello::Client.new(
        :developer_public_key => key,
        :member_token => token
      )
    end

    def user()
      @user ||= client.find(:members, ENV['TRELLOR_USERNAME'])
    end

    def boards
      @boards ||= user.boards
    end

    def board(name)
      boards.detect{ |board| board.name.downcase.start_with?(name) }
    end

    def list(board_name, list_name)
      board(board_name).lists.detect do |list|
        list.name.downcase.start_with?(list_name)
      end
    end

    def cards(board_name, list_name)
      list(board_name, list_name).cards
    end

    def card(board_name, list_name, card_name)
      list(board_name, list_name).cards.detect do |card|
        card.name==card_name
      end
    end

    def create_card(board_name, list_name, name, descript=nil)
      card = Trello::Card.new
      card.client = client
      card.list_id = list(board_name, list_name).id
      card.name = name
      card.desc = descript if descript
      card.save
    end
  end
end

