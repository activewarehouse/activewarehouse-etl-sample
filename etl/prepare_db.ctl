pre_process do
  
  ActiveRecord::Base.establish_connection(:datawarehouse)
  
  ActiveRecord::Schema.define do
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :name, :null => false
        t.string :email, :null => false
      end

      add_index :users, :email, :unique
    end
  end
  
end