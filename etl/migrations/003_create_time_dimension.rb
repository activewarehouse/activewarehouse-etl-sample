class CreateTimeDimension < ActiveRecord::Migration

  def self.up
    create_table :time_dimension do |t|
      t.time :sql_time_stamp
      
      t.integer :hour
      t.string :hour_description
      t.string :half_hour_description
      t.string :day_part
      t.string :hour_type
    end
  end
  
  def self.down
    drop_table :time_dimension
  end
  
end