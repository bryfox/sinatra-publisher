# require 'rubygems'
# require 'sinatra'
# require "#{File.expand_path(File.dirname(__FILE__))}/../lib/sinatra/publisher"

class ExampleApp < Sinatra::Base

  configure do
    set :publisher_create_zip, false
    set :publisher_respond_with_zip, false
    set :publisher_dir, 'published'
    register ::Sinatra::Publisher
  end

  get '/' do
    erb :index
  end

  get '/about-us' do
    erb :about
  end

  get '/about-us/bios' do
    "Nested directories should work."
  end

  # Single-param routes are supported.
  # Pass possible param values using define_publish_options_for
  get '/about-us/bios/:name' do
    "The bio for #{params[:name]}."
  end
  define_publish_options_for('/about-us/bios/:name', %w{foo bar baz})

end