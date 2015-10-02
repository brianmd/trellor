require 'trollop'
require 'pathname'

module Trellor
  class Cli
    def self.parse
      @opts = Trollop::options do
        banner "Usage: trellor [boardname [listname [cardname [description]]]]"
        version "trellor #{VERSION}"
        opt :cache, 'Cache (or re-cache)', short: '-c'
        opt :verbose, 'Run verbosely', short: '-v'
        opt :webapi, 'Run webapi', short: '-w'
        opt :slowtrellor, 'Make own connection rather than using webapi', short: '-s'
      end

      if webapi?
        puts 'webapi'
        require_relative 'webapi'
        run TrellorWebapi
        puts 'done?'
        sleep 10
      end

      if cache?
        hash = save_all
        p hash
      end

      process(*ARGV)
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
          WebTrellor.new
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

    def self.process(board_name=nil, list_name=nil, card_name=nil, descript=nil)
      verbose_log "board_name", board_name
      verbose_log "list_name", list_name
      verbose_log "card_name", card_name
      if board_name.nil?
        puts "Boards:", '-'*50
        trellor.board_names.each{ |name| puts name }
        # trellor.boards.each{ |board| puts board.name }
      else
        if list_name.nil?
          # board = trellor.board(board_name)
          puts "Board: #{board_name}", '-'*50
          trellor.list_names(board_name).each{ |name| puts name }
          # board.lists.each{ |list| puts list.name }
        elsif card_name.nil?
          # list = trellor.list(board_name, list_name)
          puts "List: #{board_name}.#{list_name}", '-'*50
          trellor.card_names(board_name, list_name).each{ |name| puts name }
          # list.cards.each{ |card| puts card.name }
        else
          card_names = trellor.create_card(board_name, list_name, card_name, descript)
          card_names.each{ |name| puts name }
        end
      end
    end

    def self.verbose_log(*args)
      $stderr.puts("           ****** #{args.inspect}") if @opts[:verbose]
    end

    def self.webapi?
      @opts[:webapi]
    end

    def self.cache?
      @opts[:cache]
    end
  end
end

