require File.expand_path(File.dirname(__FILE__) + '/common')

table = Commit.table_name
source_fields = [:commit_hash, :author_name, :author_date, :files_changed, :insertions, :deletions]
target_fields = [:hash, :user_id, :date_id, :time_id, :files_changed, :insertions, :deletions]

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

copy :author_date, :date_id
copy :author_date, :time_id

transform(:date_id, :string_to_date)

# look-up
transform :user_id, :foreign_key_lookup, {
  :resolver => ActiveRecordResolver.new(UserDimension, :find_by_name),
  :default => UserDimension.find_by_name(UNKNOWN_USER_NAME).id
  # TODO - investigate to understand why the SQLResolver cannot find names
  # with accents (probably some SET NAMES option)
}

transform :date_id, :foreign_key_lookup,
  :resolver => ActiveRecordResolver.new(DateDimension, :find_by_sql_date_stamp)

transform(:time_id) do |n,v,r|
  # only keep the HH:MM part before proceeding to look-up
  v[11..15]
end

transform :time_id, :foreign_key_lookup,
  :resolver => ActiveRecordResolver.new(TimeDimension, :find_by_sql_time_stamp)

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
  
  # keep the date and time as UTC for the moment, we'll store timezone in a dimension maybe
  # so the author_date of 2011-06-24 23:27:40 +0200 should be converted to:
  assert_equal "2011-06-24", commit.date.sql_date_stamp.to_s
  # rounded to the minute in our case
  assert_equal "23:27:00", commit.time.sql_time_stamp.strftime('%H:%M:%S')
  
  assert_equal 1, commit.files_changed
  assert_equal 2, commit.insertions
  assert_equal 0, commit.deletions
}
