require 'bundler'
Bundler.setup
require 'sinatra'
require 'uri'
require 'active_record'
require 'erb'
require 'coffee-script'
require 'json'

rack_env = ENV['RACK_ENV'] || 'development'
config = YAML::load(ERB.new(IO.read('config/database.yml')).result)[rack_env]
ActiveRecord::Base.establish_connection(config)

get '/' do
  haml :index
end

get '/app.js' do
  coffee :app
end