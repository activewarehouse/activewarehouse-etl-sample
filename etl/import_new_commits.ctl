require File.expand_path(File.dirname(__FILE__) + '/common')

table = 'commits'
source_fields = [:commit_hash, :author_name, :author_date, :files_changed, :insertions, :deletions]
target_fields = [:hash, :user_id, :files_changed, :insertions, :deletions]

source :git_commits,
  :file => File.expand_path(File.join(DATA_FOLDER, 'git-commits.csv')),
  :skip_lines => 1, :parser => :csv

# Ensure the fields we rely on are here on each row
after_read :ensure_fields_presence, { :fields => source_fields }

rename :commit_hash, :hash

# in RAM unicity check - duplicate rows will be removed from the pipeline
after_read :check_unique, :keys => [:hash]

# rename is an after_read with some sugar
rename :author_name, :user_id

# look-up
transform :user_id, :foreign_key_lookup, {
  :resolver => ActiveRecordResolver.new(UserDimension, :find_by_name),
  :default => UserDimension.find_by_name(UNKNOWN_USER_NAME).id
  # TODO - investigate to understand why the SQLResolver cannot find names
  # with accents (probably some SET NAMES option)
}

# here we'll just define a constant to be reused down there
bulk_load_file = File.expand_path(File.join(DATA_FOLDER, 'new_git_commits.txt'))

# write only the new records to a raw file prior to bulk loading
destination :out, { :file => bulk_load_file }, { :order => target_fields }

# then bulk-load the resulting file to the database
post_process :bulk_import, {
  :file => bulk_load_file,
  :columns => target_fields,
  :target => :datawarehouse, :table => table
}

after_post_process_screen(:fatal) {
  commit = Commit.where(:hash => '7e56bf724479ce92eff2f806573f382957f3a2b4').first
  assert_not_nil commit, "missing expected commit 7e56bf72"
  assert_equal "Xavier Noria", commit.user.name
  assert_equal 1, commit.files_changed
  assert_equal 2, commit.insertions
  assert_equal 0, commit.deletions
}