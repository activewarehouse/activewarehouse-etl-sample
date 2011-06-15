pre_process do
  
  ActiveRecord::Base.establish_connection(:datawarehouse)
  
#  ActiveRecord::Schema.drop_table(:users)
  
  ActiveRecord::Schema.define do
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :name, :null => false
      end

      add_index :users, :name, :unique
    end
  end
  
end