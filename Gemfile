source :rubygems

gem 'pg'
gem 'activerecord'

group :development do
  gem 'activewarehouse-etl', :git => 'git@github.com:activewarehouse/activewarehouse-etl.git'
  gem 'adapter_extensions',:git => 'https://github.com/activewarehouse/adapter_extensions.git'
  gem 'awesome_print'
end

group :test do
  gem 'rspec'
end

group :production do
  gem 'therubyracer'
  gem 'sinatra'
  gem 'thin'
  gem 'haml'
  gem 'coffee-script'
  gem 'coffee-filter'
end