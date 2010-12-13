require 'rubygems'
require 'sinatra'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sinatra/publisher"

# Options provided by sinatra-publisher
set :publisher_respond_with_zip, true
set :publisher_dir, 'published'

get '/' do
	# puts env.inspect
	route = get '/about' do
		'baz'
	end
	puts route.inspect
	# puts ::Sinatra::Application.send('get', [], route[3])
	erb :index
end

get '/about' do
	erb :about
end