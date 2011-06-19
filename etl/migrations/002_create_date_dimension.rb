class CreateDateDimension < ActiveRecord::Migration

  def self.up
    create_table :date_dimension do |t|
      t.string :date
      t.string :month
      t.string :day_of_week
      t.string :year
      t.string :year_and_month
      t.date :sql_date_stamp
      t.string :week
      t.string :quarter
      t.string :semester
    end
  end
  
  def self.down
    drop_table :date_dimension
  end
  
end