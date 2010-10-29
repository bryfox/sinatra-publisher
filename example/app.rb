require 'rubygems'
require 'sinatra'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sinatra/publisher"

# set :static, false

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