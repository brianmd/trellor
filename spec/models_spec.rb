require 'spec_helper'

require 'models'

module Trellor

  describe Board do
    it 'has a name that can be set via constructor' do
      board = Board.new(id: 3, name: 'board-name')
      expect(board.name).to eq('board-name')
    end

    it 'has a name that can be set via attribute' do
      board = Board.new({name: 'board-name'})
      expect(board.name).to eq('board-name')
    end

    it 'has a name that can be set via attribute later' do
      board = Board.new({name: 'board-name'})
      expect(board.name).to eq('board-name')
      board.attributes = { name: 'board--name' }
      expect(board.name).to eq('board--name')
    end

    it 'can have children' do
      lists = [ List.new(name: 'list1'), List.new(name: 'list2') ]
      board = Board.new({name: 'board-name', children: lists})
      expect(board.name).to eq('board-name')
      expect(board.children.size).to eq(2)
      expect(board.children[0].name).to eq('list1')
    end

  end

end

