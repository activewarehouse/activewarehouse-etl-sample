user_fields = {
  'an' => :author_name,
  'ae' => :author_email,
  'cn' => :committer_name,
  'ce' => :committer_email
}.to_a # use an array of array to keep order regardless of the ruby version from now on

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

pre_process do
  col_sep = "\t"
  
  git_fields = user_fields.map(&:first).map { |e| "%#{e}" }
  git_fields = git_fields.join(to_git_char(col_sep))
  csv_fields = user_fields.map(&:last)

  git_users_file = File.expand_path(File.join(DATA_FOLDER, 'git-users.csv'))

  CSV.open(git_users_file, 'w') do |output|
    output << csv_fields
    
    # here we could implement change data capture (CDC) by remembering when
    # the extraction is carried out and retrieving only the delta for 
    # subsequent calls
    cmd = "cd #{GIT_RAILS_REPO} && git log --reverse --pretty=format:\"#{git_fields}\""
    
    IO.popen(cmd).each_line do |line|
      output << line.chomp.split(col_sep)
    end
  end
end