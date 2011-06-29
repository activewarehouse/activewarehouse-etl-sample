require File.expand_path(File.dirname(__FILE__) + '/common')

table = UserDimension.table_name

# One can enable debug logging with:
#   ETL::Engine.logger = Logger.new(STDOUT)
#   ETL::Engine.logger.level = Logger::DEBUG
#
# And display rows in a processor using:
# after_read do |row| ap row; row; end

# first source to create an 'unknown' user
source :unknown_user, :type => :enumerable,
  :enumerable => [{:author_name => UNKNOWN_USER_NAME}]

# read the users csv file (options are passed to CSV/FasterCSV)
source :git_users,
  :file => File.expand_path(File.join(DATA_FOLDER, 'git-commits.csv')),
  :skip_lines => 1, :parser => :csv

# in RAM unicity check - duplicate rows will be removed from the pipeline
after_read :check_unique, :keys => [:author_name]

# use the email as name in case no name is provided
transform(:name) do |key, value, row|
  row[:author_name].blank? ? row[:author_email] : row[:author_name]
end

# remove rows that are already in the destination database
before_write :check_exist, :target => :datawarehouse, :table => table, :columns => [:name]

# here we'll just define a constant to be reused down there
bulk_load_file = File.expand_path(File.join(DATA_FOLDER, 'new_git_users.txt'))

# write only the new records to a raw file prior to bulk loading
destination :out, { :file => bulk_load_file }, { :order => [:name] }

# before the post-process, we have an opportunity to check the data
screen(:fatal) {
  IO.foreach(bulk_load_file) do |line|
    assert line.strip.size > 0, "Empty line detected in #{bulk_load_file}! This isn't expected."
  end
}

# then bulk-load the resulting file to the database
post_process :bulk_import, {
  :file => bulk_load_file,
  :columns => [:name],
  :target => :datawarehouse, :table => table
}

# after post-processes, we have another opportunity to check the data
after_post_process_screen(:fatal) {
  assert_equal 1, UserDimension.where(:name => 'Yehuda Katz').count, "More than 1 user named Yehuda Katz"
  assert_equal 0, UserDimension.where(:name => '').count, "No user should have an empty name"
  assert_equal 1, UserDimension.where(:name => 'José Valim').count, "José Valim not found"
  assert_equal 1, UserDimension.where(:name => 'Unknown user').count, "Unknown user not found"
}
