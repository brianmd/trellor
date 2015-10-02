# TODO: show card descriptions

require 'trello'
require 'net/http'
require_relative "trellor/version"

module Trellor
  class WebTrellor
    attr_accessor :be_verbose

    def get_http(url, timeout=nil)
      uri = URI("#{site}#{url}")
      http = Net::HTTP.new uri.host, uri.port
      http.open_timeout = default_open_timeout
      http.read_timeout = timeout || default_read_timeout
      request = Net::HTTP::Get.new(uri.request_uri)
      # request.basic_auth 'bh', password if password
      http.request(request)
    rescue Exception => e
      $stderr.puts "ERROR in get_http(#{url})"
      raise e
    end

    def default_open_timeout
      60
    end

    def post_http(url, data, timeout=nil)
      uri = URI("#{site}#{url}")
      http = Net::HTTP.new uri.host, uri.port
      http.open_timeout = default_open_timeout
      http.read_timeout = timeout || default_read_timeout
      request = Net::HTTP::Post.new(uri.request_uri)
      # request.basic_auth 'bh', password if password

      request.set_form_data data
      http.request(request)
    rescue Exception => e
      $stderr.puts "ERROR in post_http(#{url})"
      raise e
    end

    def default_open_timeout
      @default_open_timeout ||= (ENV['TRELLOR_OPEN_TIMEOUT'] || 5).to_i
    end

    def default_read_timeout
      @default_read_timeout = (ENV['TRELLOR_READ_TIMEOUT'] || 30).to_i
    end

    def site
      "http://localhost:#{port}"
    end
    def port
      4567
    end

    def verbose_log(*args)
      $stderr.puts("           ****** #{args.inspect}") if be_verbose
    end

    def user()
      verbose_log('username', ENV['TRELLOR_USERNAME'])
      @user ||= client.find(:members, ENV['TRELLOR_USERNAME'])
    end

    def board_names
      verbose_log('getting boards') unless @boards
      @boards = JSON.parse(get_http('/boards').body)
      #@boards ||= user.boards.select{ |b| !b.closed? }
    end

    def list_names(board_name)
      JSON.parse(get_http("/boards/#{board_name}/lists").body)
    end

    def card_names(board_name, list_name)
      JSON.parse(get_http("/boards/#{board_name}/lists/#{list_name}/cards").body)
    end

    def create_card(board_name, list_name, name, descript=nil)
      JSON.parse(get_http("/boards/#{board_name}/lists/#{list_name}/cards/#{name}").body)
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
  end
end

