require 'bundler'
Bundler.setup

require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new

task :rocco do
  require 'rocco'
  
  files = [
    'etl/process_all.ebf',
    'etl/extract.ctl'
    'etl/prepare_db.ctl',
    'etl/migrations/001_create_users.rb',
  ]
  
  data = files.map do |file|
    "#### #{file}\n\n" + IO.read(file)
  end.join("\n\n")

  File.open(File.dirname(__FILE__) + '/index.html', 'w') do |output|
    output << Rocco.new("ActiveWarehouse-ETL sample", [], {}) { data }.to_html
  end
end
