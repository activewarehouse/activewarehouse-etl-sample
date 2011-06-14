# You can require regular ruby code from here
require File.dirname(__FILE__) + '/common'

# One can enable debug logging with:
#   ETL::Engine.logger = Logger.new(STDOUT)
#   ETL::Engine.logger.level = Logger::DEBUG

# Read the users csv file (options are passed to CSV/FasterCSV)
source :git_users,
  :file => File.expand_path(File.join(DATA_FOLDER, 'git-users.csv')),
  :skip_lines => 1, :parser => :delimited

# This after read processor generates two output rows for one input row
after_read do |row|
  [
    { :name => row[:author_name], :email => row[:author_email] },
    { :name => row[:committer_name], :email => row[:committer_email] }
  ]
end

# In RAM unicity check - duplicate rows will be removed from the pipeline
after_read :check_unique, :keys => [:email]
  
# You can use a block to achieve whatever you want
# Just remember to return the row at the end
after_read do |row|
  ap row
  row
end