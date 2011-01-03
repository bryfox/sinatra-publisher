require 'rubygems'
require 'sinatra'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sinatra/publisher"

# Options provided by sinatra-publisher
set :publisher_create_zip, false
set :publisher_respond_with_zip, false
set :publisher_dir, '/Users/bryan/Sites/published'

get '/' do
	erb :index
end

get '/about' do
	erb :about
end