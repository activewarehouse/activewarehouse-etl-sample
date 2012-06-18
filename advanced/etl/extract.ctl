require File.expand_path(File.dirname(__FILE__) + '/common')

pre_process do
  if File.exist?(GIT_RAILS_REPO)
    system! "cd #{GIT_RAILS_REPO} && git pull"
  else
    system! "git clone https://github.com/rails/rails #{GIT_RAILS_REPO}"
  end
end

def to_git_char(char)
  "%x" + char.ord.to_s(16).rjust(2, "0")
end

git_commits_file = File.expand_path(File.join(DATA_FOLDER, 'git-commits.csv'))

pre_process do
  commit_fields = {
    'H'  => :commit_hash,
    'an' => :author_name,
    'ae' => :author_email,
    'ai' => :author_date
  }.to_a

  col_sep = "\t"
  
  git_fields = commit_fields.map(&:first).map { |e| "%#{e}" }
  git_fields = git_fields.join(to_git_char(col_sep))
  csv_fields = commit_fields.map(&:last) + [:files_changed, :insertions, :deletions]

  CSV.open(git_commits_file, 'w') do |output|
    output << csv_fields
    
    cmd = "cd #{GIT_RAILS_REPO} && git log --shortstat --reverse --pretty=format:\"#{git_fields}\""
   
    buffer = []
    
    IO.popen(cmd).each_line do |line|
      case line
        when /^[0-9a-f]{40}/;
          buffer << 0 << 0 << 0 unless buffer.size == csv_fields.size || buffer.empty?
          output << buffer unless buffer.empty?
          buffer = line.strip.split(col_sep)
        when /(\d+) files changed, (\d+) insertions\(\+\), (\d+) deletions\(\-\)/;
          buffer << $1 << $2 << $3
        when "\n";
        else raise "Failed to parse line #{line.inspect}"
      end
    end

    buffer << 0 << 0 << 0 unless buffer.size == csv_fields.size || buffer.empty?
    output << buffer unless buffer.empty?
  end
  
end

screen(:fatal) do
  assert_equal %w(commit_hash author_name author_email author_date files_changed insertions deletions),
    CSV.parse_line(IO.popen("head -1 #{git_commits_file}").read)
  
  assert_equal [
    "20d7d2415f99620590aec07cedcaace34cced1c6",
    "Xavier Noria",
    "fxn@hashref.com",
    "2011-06-18 10:14:32 +0200",
    "2",
    "3",
    "3"
  ], CSV.parse_line(IO.popen("grep 20d7d2415f99620590aec07cedcaace34cced1c6 #{git_commits_file}").read)
  
  # when no stat is provided, 0/0/0 should still be stored
  row_with_no_file_changes = CSV.parse_line(IO.popen("grep b3f45195aa8a35277c3f998917312797936a1f4e #{git_commits_file}").read)

  assert_equal [
    "b3f45195aa8a35277c3f998917312797936a1f4e",
    "0",
    "0",
    "0"
  ], [
    row_with_no_file_changes[0],
    row_with_no_file_changes[-1],
    row_with_no_file_changes[-2],
    row_with_no_file_changes[-3],
  ]
end