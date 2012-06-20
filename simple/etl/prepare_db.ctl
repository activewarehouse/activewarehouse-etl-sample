pre_process do
  migrations_folder = File.expand_path(File.dirname(__FILE__) + '/migrations')
  version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
  
  ActiveRecord::Base.establish_connection(:datawarehouse)
  ActiveRecord::Migrator.migrate(migrations_folder, version)
end