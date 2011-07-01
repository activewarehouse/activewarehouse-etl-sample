require 'bundler'
Bundler.setup
require 'sinatra'
require 'uri'
require 'active_record'
require 'erb'

rack_env = ENV['RACK_ENV'] || 'development'
config = YAML::load(ERB.new(IO.read('config/database.yml')).result)[rack_env]
ActiveRecord::Base.establish_connection(config)

get '/' do
  count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM commits")
  "We have #{count} commits registered - RACK_ENV=#{rack_env.inspect}"
end
