class CreateUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string :name, :null => false
    end
    
    add_index :users, :name, :unique
  end
  
  def self.down
    drop_table :users
  end
  
end