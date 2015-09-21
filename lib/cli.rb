require 'optparse'

module Trellor
  class Cli
    def self.parse(*args)
    #def self.parse(board_and_list=nil, card_name=nil, descript=nil)
      options = OpenStruct.new
      options.force = false
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
          options.force = true
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

    def self.process(board_and_list=nil, card_name=nil, descript=nil)
      trellor = Trellor.new
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

