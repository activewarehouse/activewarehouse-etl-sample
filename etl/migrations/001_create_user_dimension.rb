class CreateUserDimension < ActiveRecord::Migration

  def change
    create_table :user_dimension, :force => true do |t|
      t.string :name, :null => false
    end

    # work-around: mysql bulk load will choke on "Adam" vs "adam", considering these are duplicates
    # as well: we use self. because of https://github.com/activewarehouse/activewarehouse-etl/issues/70
    self.execute %{ALTER TABLE user_dimension MODIFY name varchar(255) COLLATE utf8_bin NOT NULL}
    
    add_index :user_dimension, :name, :unique
  end
  
end