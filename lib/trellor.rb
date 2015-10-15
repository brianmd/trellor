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

    ############  connecting  ###############

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


    ##############  trellor interface  ###############

    def board_names
      boards.collect{ |board| board.name }.sort_by{|name| name.downcase}
    end
    def list_names(board_name)
      find_board(board_name).lists.collect{ |list| list.name }.sort_by{|name| name.downcase}
    end
    def card_names(board_name, list_name)
      find_list(board_name, list_name).cards.collect{ |card| card.name }
    end
    def create_card(board_name, list_name, name, descript=nil)
      card = Trello::Card.new
      card.client = client
      card.list_id = find_list(board_name, list_name).id
      card.name = name
      card.desc = descript if descript
      card.save
    end
    def archive_card(board_name, list_name, name)
      card = find_card(board_name, list_name, name)
      card.close!
    end



    ################  queries  #################

    def boards
      verbose_log('getting boards') unless @boards
      @boards ||= user.boards.select{ |b| !b.closed? }
    end
    def boards=(boards)
      @boards = boards
    end

    def find_board(name)
      boards   # to get verbose log ordering correct
      verbose_log('getting board', name)
      name = Regexp.new(name, Regexp::IGNORECASE)
      boards.find{ |board| name.match(board.name) }
    end

    def find_list(board_name, list_name)
      this_board = find_board(board_name)
      verbose_log('   getting list', board_name, list_name)
      name = Regexp.new(list_name, Regexp::IGNORECASE)
      this_board.lists.find{ |list| name.match(list.name) }
    end

    def cards(board_name, list_name)
      verbose_log('       getting cards for', board_name, list_name)
      find_list(board_name, list_name).cards
    end

    def find_card(board_name, list_name, card_name)
      this_list = list(board_name, list_name)
      verbose_log('   getting card', board_name, list_name, card_name)
      name = Regexp.new(card_name, Regexp::IGNORECASE)
      this_list.cards.find{ |card| name.match(card.name) }
    end
  end
end

