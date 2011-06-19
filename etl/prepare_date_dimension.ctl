require File.expand_path(File.dirname(__FILE__) + '/common')

table = 'date_dimension'
bulk_load_file = "#{table}.txt"
start_date = Date.parse('2000-01-01')
end_date = Date.parse('2020-01-01')

pre_process :truncate, :target => :datawarehouse, :table => table

records = DateDimensionBuilder.new(start_date, end_date).build

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

  class DateDimension < ActiveRecord::Base; end
  DateDimension.table_name = table

  assert_equal end_date - start_date + 1, DateDimension.count

  # ensure we keep constant ids despite the truncating
  assert_equal start_date, DateDimension.find(1).sql_date_stamp
end