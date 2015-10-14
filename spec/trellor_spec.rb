require 'spec_helper'

describe Trellor do

  before(:all) {
    @trellor = Trellor::Trellor.new
  }

  it 'has a board that starts with "to"' do
    # this finds my ToDo board
    expect(@trellor.board('to')).not_to be_nil
  end

  it 'has a list that starts with "in" in board "to"' do
    # this finds my Inbox list inside the ToDo board
    expect(@trellor.list('to','in')).not_to be_nil
  end

  it 'can create a card and read it back' do
    card_name = "test #{Time.now}"
    @trellor.create_card('to', 'in', card_name)
    cards = @trellor.cards('to','in')
    card = cards.find{ |c| c.name==card_name }
    expect(card.name).to eq(card_name)
    expect(@trellor.find_card('to', 'in', card_name)).to eq(card)
  end

end
