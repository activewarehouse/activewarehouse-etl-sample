# One can enable debug logging with:
#   ETL::Engine.logger = Logger.new(STDOUT)
#   ETL::Engine.logger.level = Logger::DEBUG
#
# And display rows in a processor using:
# after_read do |row| ap row; row; end

# read the users csv file (options are passed to CSV/FasterCSV)
source :git_users,
  :file => File.expand_path(File.join(DATA_FOLDER, 'git-users.csv')),
  :skip_lines => 1, :parser => :delimited

# this after read processor generates two output rows for one input row
after_read do |row|
  [
    { :name => row[:author_name], :email => row[:author_email] },
    { :name => row[:committer_name], :email => row[:committer_email] }
  ]
end

after_read do |row|
  ap row if row[:name] =~ /utf/
  row
end

# in RAM unicity check - duplicate rows will be removed from the pipeline
after_read :check_unique, :keys => [:name]

# use the email as name in case no name is provided
transform(:name) do |key, value, row|
  row[:name].blank? ? row[:email] : row[:name]
end

# remove rows that are already in the destination database
before_write :check_exist, :target => :datawarehouse, :table => 'users', :columns => [:name]

# here we'll just define a constant to be reused down there
BULK_LOAD_FILE = File.expand_path(File.join(DATA_FOLDER, 'new_git_users.txt'))

# write only the new records to a raw file prior to bulk loading
destination :out, { :file => BULK_LOAD_FILE }, { :order => [:name] }

# before the post-process, we have an opportunity to check the data
screen(:fatal) {
  IO.foreach(BULK_LOAD_FILE) do |line|
    assert line.strip.size > 0, "Empty line detected in #{BULK_LOAD_FILE}! This isn't expected."
  end
}

# then bulk-load the resulting file to the database
post_process :bulk_import, {
  :file => BULK_LOAD_FILE,
  :columns => [:name],
  :target => :datawarehouse, :table => 'users'
}

# after post-processes, we have another opportunity to check the data
after_post_process_screen(:fatal) {
  # we can use AR or any other ruby tool in there:
  class User < ActiveRecord::Base; end
  
  assert_equal 1, User.where(:name => 'Yehuda Katz').count, "More than 1 user named Yehuda Katz"
  
  assert_equal 0, User.where(:name => '').count, "No user should have an empty name"
}

