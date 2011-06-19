require 'awesome_print'

$: << File.dirname(__FILE__) + '/../lib'

require 'date_dimension_builder'

DATA_FOLDER = File.dirname(__FILE__) + '/../data'

GIT_RAILS_REPO = File.join(DATA_FOLDER, 'git_rails')

# fail-fast process execution
def system!(cmd)
  raise "Failed to run command #{cmd}" unless system(cmd)
end