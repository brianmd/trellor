require 'sinatra'
require 'json'
require_relative 'trellor'

module Trellor
  class TrellorWebapi < Sinatra::Base
    get '/' do
      "Hello, world!"
    end
  end
end

def trellor
  Trellor::Trellor.singleton
end

get '/' do
  "Hello, world!"
end

get '/boards' do
  boards = trellor.board_names
  boards.to_json
end

get '/boards/:board_name/lists' do
  lists = trellor.board(params['board_name']).lists.collect{ |list| list.name }
  lists.to_json
end

get '/boards/:board_name/lists/:list_name/cards' do
  cards = trellor.list(params['board_name'],params['list_name']).cards.collect{ |card| card.name }
  cards.to_json
end

get '/bbboards/:board_name/lists/:list_name/cards/:card_name' do
  card = trellor.list(params['board_name'],params['list_name'],params['card_name'])
  card.to_json
end

post '/boards/:board_name/lists/:list_name/cards' do
  card = Trello::Card.new
  card.client = trellor.client
  card.list_id = trellor.list(params['board_name'],params['list_name']).id
  card.name = params['card_name']
  card.save

  cards = trellor.list(params['board_name'],params['list_name']).cards.collect{ |c| c.name }
  cards.to_json
end

