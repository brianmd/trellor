# TODO: show card descriptions

require 'trello'
require 'net/http'
require 'pathname'
require 'addressable/uri'
require_relative "trellor/version"

module Trellor
  class WebTrellor
    attr_accessor :be_verbose

    def ensure_webapp_is_running(fork=true)
      v = get_version
      $stderr.puts "Warning: this version is #{VERSION} but the webapp version is #{v}. You may want to kill the older webapp." unless (!v or (v==VERSION))
      fail unless v
    rescue
      puts "The background webapp wasn't running. Will run it now."
      verbose_log "The background webapp wasn't running. Will run it now."
      run_webapp(fork)
    end

    def run_webapp(fork)
      path = Pathname.new(__FILE__).parent.parent
      cmd = "cd '#{path}' && ruby lib/webapi.rb &> /dev/null"
      verbose_log cmd
      unless fork
        $stderr.puts 'running ...'
        exec cmd
        exit 0
      end
      job = fork do
        exec cmd
      end
      # give webapp time to run before returning
      (1..30).each do |n|
        verbose_log '.'
        sleep 0.1
        ver = get_version
        return if ver and ver!=''
      end
      Process.detach(job)
    end

    def get_version
      response = get_http('/version', nil, nil, false)
      response.body
    rescue
      nil
    end


    ##############  trellor interface queries  ###############

    def board_names
      verbose_log('getting boards') unless @boards
      @boards = JSON.parse(get_http('/boards').body)
      #@boards ||= user.boards.select{ |b| !b.closed? }
    end

    def list_names(board_name)
      JSON.parse(get_http("/boards", {board_name: board_name}).body)
    end

    def card_names(board_name, list_name)
      JSON.parse(get_http("/boards", {board_name: board_name, list_name: list_name}).body)
    end

    def create_card(board_name, list_name, name, descript=nil)
      JSON.parse(post_http("/boards/#{board_name}/lists/#{list_name}/cards", {card_name: name, descript: descript}).body)
    end

    def archive_card(board_name, list_name, name)
      JSON.parse(post_http("/boards/#{board_name}/lists/#{list_name}/cards", {card_name: name, archive: true}).body)
    end


    private

    #################  private  ################

    def get_http(url, data=nil, timeout=nil, show_error=true)
      uri = Addressable::URI.parse("#{site}#{url}")
      http = Net::HTTP.new uri.host, uri.port
      http.open_timeout = default_open_timeout
      http.read_timeout = timeout || default_read_timeout
      request = Net::HTTP::Get.new(uri.request_uri)
      # request.basic_auth 'trellor', password if password
      request.set_form_data data if data
      response = http.request(request)
      verbose_log response.code, response.body
      response
    rescue Exception => e
      $stderr.puts "ERROR in get_http(#{url})" if show_error
      raise e
    end

    def post_http(url, data, timeout=nil, show_error=true)
      uri = URI("#{site}#{url}")
      http = Net::HTTP.new uri.host, uri.port
      http.open_timeout = default_open_timeout
      http.read_timeout = timeout || default_read_timeout
      request = Net::HTTP::Post.new(uri.request_uri)
      # request.basic_auth 'trellor', password if password

      request.set_form_data data
      response = http.request(request)
      verbose_log response.code, response.body
      response
    rescue Exception => e
      $stderr.puts "ERROR in post_http(#{url})" if show_error
      raise e
    end

    def default_open_timeout
      @default_open_timeout ||= (ENV['TRELLOR_OPEN_TIMEOUT'] || 1).to_i
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

    # def user()
      # verbose_log('username', ENV['TRELLOR_USERNAME'])
      # @user ||= client.find(:members, ENV['TRELLOR_USERNAME'])
    # end





    # def board(name)
      # boards   # to get verbose log ordering correct
      # verbose_log('getting board', name)
      # name = name.downcase
      # boards.detect{ |board| board.name.downcase.start_with?(name) }
    # end

    # def list(board_name, list_name)
      # this_board = board(board_name)
      # verbose_log('   getting list', board_name, list_name)
      # list_name = list_name.downcase
      # this_board.lists.detect do |list|
        # list.name.downcase.start_with?(list_name)
      # end
    # end

    # def cards(board_name, list_name)
      # verbose_log('       getting cards for', board_name, list_name)
      # list(board_name, list_name).cards
    # end

    # def card(board_name, list_name, card_name)
      # list(board_name, list_name).cards.detect do |card|
        # card.name==card_name
      # end
    # end
  end
end

