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

get '/boards/:board_name/lists' do |board_name|
  lists = trellor.list_names(board_name)
  lists.to_json
end

get '/boards/:board_name/lists/:list_name/cards' do |board_name, list_name|
  cards = trellor.list(board_name,list_name).cards.collect{ |card| card.name }
  cards.to_json
end

get '/bbboards/:board_name/lists/:list_name/cards/:card_name' do
  card = trellor.list(params['board_name'],params['list_name'],params['card_name'])
  card.to_json
end

post '/boards/:board_name/lists/:list_name/cards' do |board_name, list_name|
  card = Trello::Card.new
  card.client = trellor.client
  card.list_id = trellor.list(board_name,list_name).id
  card.name = params['card_name']
  card.save

  cards = trellor.list(board_name,list_name).cards.collect{ |c| c.name }
  cards.to_json
end

