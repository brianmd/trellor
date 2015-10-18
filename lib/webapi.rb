require 'sinatra'
require 'yajl/json_gem'
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
  # log = Logger.new(File.new('log','a'))
  msg = 'Sorry there was a error: ' + env['sinatra.error'].message
  logger.error msg
  env['sinatra.error'].backtrace.each{|l| logger.error l}
  msg
end

helpers do
 def logger
   unless @logger
     @logger = Trellor::Trellor.logger
     @logger.progname = '[webapi]'
   end
   @logger
 end
end

def trellor
  Trellor::Trellor.singleton
end

get '/version' do
  Trellor::VERSION
end

get '/boards' do
  if params[:list_name]
    logger.info params.inspect
    # cards = trellor.list_names(params[:board_name],params[:list_name]).cards.collect{ |card| card.name }
    cards = trellor.card_names(params[:board_name],params[:list_name])
    cards.to_json
  elsif params[:board_name]
    lists = trellor.list_names(params[:board_name])
    lists.to_json
  else
    boards = trellor.board_names
    boards.to_json
  end
end

post '/boards' do
  board_name = params['board_name']
  list_name = params['list_name']
  if params['archive']
    trellor.archive_card(board_name, list_name, params['card_name'])
  else
    trellor.create_card(board_name, list_name, params['card_name'], params['descript'])
  end

  cards = trellor.card_names(board_name,list_name)
  cards.to_json
  params.to_json
end

# post '/boards/:board_name/lists/:list_name/cards' do |board_name, list_name|
  # if params['archive']
    # trellor.archive_card(board_name, list_name, params['card_name'])
  # else
    # trellor.create_card(board_name, list_name, params['card_name'], params['descript'])
  # end

  # cards = trellor.list(board_name,list_name).cards.collect{ |c| c.name }
  # cards.to_json
  # params.to_json
# end

