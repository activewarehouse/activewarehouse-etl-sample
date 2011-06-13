require File.dirname(__FILE__) + '/common'

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

pre_process do
  git_fields = user_fields.map(&:first).map { |e| "%#{e}" }.join('%x2C')
  csv_fields = user_fields.map(&:last)

  git_users_file = File.expand_path(File.join(DATA_FOLDER, 'git-users.csv'))

  File.open(git_users_file, 'w') do |file|
    file << csv_fields.join(',') + "\n"
  end
  
  system! "cd #{GIT_RAILS_REPO} && git log --pretty=format:\"#{git_fields}\" >> #{git_users_file}"
end