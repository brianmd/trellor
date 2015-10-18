require 'trollop'
require 'pathname'

module Trellor
  class Cli
    def self.parse
      logger  # sets the logger's progname
      @opts = Trollop::options do
        banner "Usage: trellor [boardname [listname [cardname [description]]]]"
        version "trellor #{VERSION}"
        opt :archive, 'Archive a card', short: '-a'
        opt :cache, 'Cache (or re-cache)', short: '-c'
        opt :verbose, 'Run verbosely', short: '-v'
        opt :webapi, 'Run webapi', short: '-w'
        opt :slowtrellor, 'Make own connection rather than using webapi', short: '-s'
      end

      if webapi?
        require_relative 'web_trellor'
        web = WebTrellor.new
        web.be_verbose = true if @opts[:verbose]
        web.ensure_webapp_is_running(false)
        exit 0
      end

      if cache?
        hash = save_all
        p hash
      end

      query_trellor(*ARGV)
    end

    private

    def self.trellor
      unless @trellor
        verbose_log('creating Trellor instance')
        @trellor = if @opts[:slowtrellor]
          verbose_log('using local (slower) trellor')
          Trellor.new
        else
          verbose_log('using webapi')
          require_relative 'web_trellor'
          web = WebTrellor.new
          web.be_verbose = true if @opts[:verbose]
          web.ensure_webapp_is_running
          web
        end
        @trellor.be_verbose = true if @opts[:verbose]
      end
      @trellor
    end
    
    def self.homepath
      Pathname.new(ENV['HOME'])
    end
    def self.filepath
      homepath + '.config/.trellor'
    end

    def self.save_all
      path = homepath + '.config'
      path.mkdir unless path.directory?
      hash = all
      filepath.open('w') do |out|
        out.puts JSON.pretty_generate(hash)
      end
      hash
    end

    def self.get_all
      JSON.parse(filepath.read)
    end

    def self.all
      verbose_log('downloading all boards and lists')
      hash = {}
      trellor.boards.each do |board|
        verbose_log('downloading board', board.name)
        lists = {}
        board.lists.each{ |l| lists[l.name] = l.id }
        hash[board.name] = { id: board.id, lists: lists }
      end
      hash
    end

    def self.query_trellor(board_name=nil, list_name=nil, card_name=nil, descript=nil)
      verbose_log "board_name", board_name
      verbose_log "list_name", list_name
      verbose_log "card_name", card_name
      if board_name.nil?
        puts "Boards:", '-'*50
        trellor.board_names.each{ |name| puts name }
      elsif list_name.nil?
        puts "Lists for Board: #{board_name}", '-'*50
        trellor.list_names(board_name).each{ |name| puts name }
      elsif card_name.nil?
        puts "Cards for List: #{board_name}.#{list_name}", '-'*50
        trellor.card_names(board_name, list_name).each{ |name| puts name }
      elsif archive?
        trellor.archive_card(board_name, list_name, card_name)
        trellor.card_names(board_name, list_name).each{ |name| puts name }
      else
        trellor.create_card(board_name, list_name, card_name, descript)
        trellor.card_names(board_name, list_name).each{ |name| puts name }
      end
    end

    def self.verbose_log(*args)
      logger.info("           ****** #{args.inspect}") if @opts[:verbose]
    end

    def self.logger
      unless @logger
        @logger = Trellor.logger
        @logger.progname = '[cli]'
      end
      @logger
    end

    def self.webapi?
      @opts[:webapi]
    end

    def self.archive?
      @opts[:archive]
    end

    def self.cache?
      @opts[:cache]
    end
  end
end

