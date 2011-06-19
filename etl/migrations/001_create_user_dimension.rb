class CreateUserDimension < ActiveRecord::Migration

  def self.up
    create_table :user_dimension do |t|
      t.string :name, :null => false
    end
    
    add_index :user_dimension, :name, :unique
  end
  
  def self.down
    drop_table :user_dimension
  end
  
end