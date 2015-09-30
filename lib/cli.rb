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
        @trellor = Trellor.new
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
        trellor.boards.each{ |board| puts board.name }
      else
        if list_name.nil?
          board = trellor.board(board_name)
          puts "Board: #{board.name}", '-'*50
          board.lists.each{ |list| puts list.name }
        elsif card_name.nil?
          list = trellor.list(board_name, list_name)
          puts "List: #{list.name}", '-'*50
          list.cards.each{ |card| puts card.name }
        else
          trellor.create_card(board_name, list_name, card_name, descript)
        end
      end
    end

    def self.verbose_log(*args)
      $stderr.puts("           ****** #{args.inspect}") if @opts[:verbose]
    end

    def self.cache?
      @opts[:cache]
    end
  end
end

