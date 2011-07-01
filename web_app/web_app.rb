require 'bundler'
Bundler.setup
require 'sinatra'
require 'uri'
require 'active_record'

config = YAML::load(IO.read('config/database.yml'))['development']

ActiveRecord::Base.establish_connection(config)

get '/' do
  count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM commits")
  "We have #{count} commits registered - RACK_ENV=#{ENV['RACK_ENV'].inspect}"
end
