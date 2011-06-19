require File.expand_path(File.dirname(__FILE__) + '/common')

table = 'date_dimension'

pre_process :truncate, :target => :datawarehouse, :table => table

records = DateDimensionBuilder.new("2000-01-01", "2050-01-01").build

source :in, {
  :type => :enumerable,
  :enumerable => records,
  :store_locally => false
}

columns = records.first.keys

BULK_LOAD_FILE = 'date_dimension.txt'

# write only the new records to a raw file prior to bulk loading
destination :out, { :file => BULK_LOAD_FILE }, { :order => columns }

# then bulk-load the resulting file to the database
post_process :bulk_import, {
  :file => BULK_LOAD_FILE,
  :columns => columns,
  :target => :datawarehouse, :table => table
}

after_post_process_screen(:fatal) do
  class DateDimension < ActiveRecord::Base
    set_table_name 'date_dimension'
  end
  
  ActiveRecord::Base.establish_connection(:datawarehouse)
  
  assert_equal Date.parse('2050-01-01') - Date.parse('2000-01-01') + 1,
    DateDimension.count
    
  # ensure we keep constant ids despite the truncating
  assert_equal '2000-01-01', DateDimension.find(1).date
end