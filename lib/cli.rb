require 'optparse'
require 'pathname'

module Trellor
  class Cli
    def self.parse(*args)
      options = OpenStruct.new
      options.force_cache = false
      options.verbose = false

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: trellor [boardname[.listname [cardname [description]]]]"

        opts.separator ""
        opts.separator "Specific options:"

        # Mandatory argument.
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |lib|
          options.verbose = true
        end

        opts.on("-f", "--force", "Force re-caching") do |lib|
          options.force_cache = true
          hash = save_all
          puts hash
        end

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts ::Trellor::VERSION
          exit
        end
   
      end
      opt_parser.parse!(args)

      process(*args)
    end

    def self.trellor
      @trellor ||= Trellor.new
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
      hash = {}
      trellor.boards.each do |board|
        lists = {}
        board.lists.each{ |l| lists[l.name] = l.id }
        hash[board.name] = { id: board.id, lists: lists }
      end
      hash
    end

    def self.process(board_and_list=nil, card_name=nil, descript=nil)
      if board_and_list.nil?
        puts "Boards:", '-'*50
        trellor.boards.each{ |board| puts board.name }
      else
        board_name, list_name = board_and_list.split('.')
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
  end
end

