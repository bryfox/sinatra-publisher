# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'rubygems'
require 'sinatra'
require 'lib/sinatra/publisher'
 
Gem::Specification.new do |s|
  s.name        = "sinatra-publisher"
  s.version     = Sinatra::Publisher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Bryan Fox"
  s.email       = "bryfox@gmail.com"
  s.homepage    = "http://github.com/bryfox/sinatra-publisher"
  s.summary     = "Publish an erb-based sinatra app out to static HTML files."
  s.description = "Use sinatra to build a templated site which can be published out to static HTML and hosted without infrastructure"
 
  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md)
  s.require_path = 'lib'
end