# TODO: show card descriptions

require_relative "trellor/version"
require 'trello'

module Trellor
  class Trellor
    attr_accessor :be_verbose

    def self.singleton
      unless @singleton
        puts 'getting singleton'
        @singleton = self.new
      end
      @singleton
    end

    def client(key=ENV['TRELLOR_KEY'], token=ENV['TRELLOR_TOKEN'])
      @client ||= connect(key, token)
    end

    def connect(key=ENV['TRELLOR_KEY'], token=ENV['TRELLOR_TOKEN'])
      verbose_log("connecting with", key, token)
      Trello::Client.new(
        :developer_public_key => key,
        :member_token => token
      )
    end

    def verbose_log(*args)
      $stderr.puts("           ****** #{args.inspect}") if be_verbose
    end

    def user()
      verbose_log('username', ENV['TRELLOR_USERNAME'])
      @user ||= client.find(:members, ENV['TRELLOR_USERNAME'])
    end

    def boards
      verbose_log('getting boards') unless @boards
      @boards ||= user.boards.select{ |b| !b.closed? }
    end
    def boards=(boards)
      @boards = boards
    end

    def board(name)
      boards   # to get verbose log ordering correct
      verbose_log('getting board', name)
      name = name.downcase
      boards.detect{ |board| board.name.downcase.start_with?(name) }
    end

    def list(board_name, list_name)
      this_board = board(board_name)
      verbose_log('   getting list', board_name, list_name)
      list_name = list_name.downcase
      this_board.lists.detect do |list|
        list.name.downcase.start_with?(list_name)
      end
    end

    def cards(board_name, list_name)
      verbose_log('       getting cards for', board_name, list_name)
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

