require 'sinatra'
require 'json'
require_relative 'trellor/version'
require_relative 'trellor'


module Trellor
  class TrellorWebapi < Sinatra::Base
    # enable error handler even in development mode
    set :show_exceptions, :after_handler

    not_found do
      'no such path'
    end

    error do
      'had an error'
    end

  end
end


set :show_exceptions, false

not_found do
  'no such path'
end

error do
  'had an error'
end


def trellor
  Trellor::Trellor.singleton
end

get '/version' do
  Trellor::VERSION
end

get '/boards' do
  if params[:list_name]
    cards = trellor.list(params[:board_name],params[:list_name]).cards.collect{ |card| card.name }
    cards.to_json
  elsif params[:board_name]
    lists = trellor.list_names(params[:board_name])
    lists.to_json
  else
    boards = trellor.board_names
    boards.to_json
  end
end

post '/boards/:board_name/lists/:list_name/cards' do |board_name, list_name|
  if params['archive']
    trellor.archive_card(board_name, list_name, params['card_name'])
  else
    trellor.create_card(board_name, list_name, params['card_name'], params['descript'])
  end

  cards = trellor.list(board_name,list_name).cards.collect{ |c| c.name }
  cards.to_json
  params.to_json
end

