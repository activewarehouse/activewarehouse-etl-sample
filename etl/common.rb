require 'awesome_print'

$: << File.dirname(__FILE__) + '/../lib'

require 'date_dimension_builder'
require 'time_dimension_builder'

DATA_FOLDER = File.dirname(__FILE__) + '/../data'

GIT_RAILS_REPO = File.join(DATA_FOLDER, 'git_rails')

UNKNOWN_USER_NAME = 'Unknown user'

# fail-fast process execution
def system!(cmd)
  raise "Failed to run command #{cmd}" unless system(cmd)
end

# define a couple of ActiveRecord models for later re-use (not mandatory)

class UserDimension < ActiveRecord::Base; end
UserDimension.table_name = 'user_dimension'

class Commit < ActiveRecord::Base
  # TODO - rename as :author
  belongs_to :user, :class_name => 'UserDimension'
end

# TODO - figure out why this is required here
ActiveRecord::Base.establish_connection(:datawarehouse)
