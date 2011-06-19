require File.expand_path(File.dirname(__FILE__) + '/common')

# you will notice this file is very, very similar to prepare_date_dimension
# so similar you can create a ruby method into common.rb or another file
# to DRY things - it will definitely work.

table = 'time_dimension'
bulk_load_file = "#{table}.txt"

pre_process :truncate, :target => :datawarehouse, :table => table

records = TimeDimensionBuilder.new("0:00", "23:59").build

source :in, {
  :type => :enumerable,
  :enumerable => records,
  :store_locally => false
}

# pick the first record to extract the column names
columns = records.first.keys


# write only the new records to a raw file prior to bulk loading
destination :out, { :file => bulk_load_file }, { :order => columns }

# then bulk-load the resulting file to the database
post_process :bulk_import, {
  :file => bulk_load_file,
  :columns => columns,
  :target => :datawarehouse, :table => table
}

after_post_process_screen(:fatal) do
  ActiveRecord::Base.establish_connection(:datawarehouse)

  class TimeDimension < ActiveRecord::Base; end
  TimeDimension.table_name = table
  
  assert_equal 60*24, TimeDimension.count
    
  # ensure we keep constant ids despite the truncating
  assert_equal '00:00', TimeDimension.find(1).sql_time_stamp.strftime("%H:%M")
  assert_equal '23:59', TimeDimension.find(60*24).sql_time_stamp.strftime("%H:%M")
end