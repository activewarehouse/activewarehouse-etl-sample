require 'bundler'
Bundler.setup

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
