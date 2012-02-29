source :rubygems

# use our own fork for bulk load support until issue fixed:
# https://github.com/brianmario/mysql2/pull/242
gem 'mysql2', :git => 'git://github.com/activewarehouse/mysql2.git'

#gem 'mysql2'

gem 'activewarehouse-etl', :git => 'https://github.com/activewarehouse/activewarehouse-etl.git'
#gem 'activewarehouse-etl', :path => '~/git/activewarehouse-etl'
gem 'adapter_extensions',:git => 'https://github.com/activewarehouse/adapter_extensions.git', :branch => 'rails-3'
gem 'awesome_print'

group :test do
  gem 'rspec'
end
