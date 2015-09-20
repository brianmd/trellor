module Trellor
  class Cli
    def self.parse(board_and_list=nil, card_name=nil, descript=nil)
      trellor = Trellor.new
      if board_and_list.nil?
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

