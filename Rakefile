require 'bundler'
Bundler.setup

task :extract do
  extract_folder = File.join(File.dirname(__FILE__), 'data')
  FileUtils.mkdir(extract_folder) unless File.exist?(extract_folder)
  rails_repo_folder = File.join(extract_folder, 'git_rails')
  if File.exist?(rails_repo_folder)
    sh "cd #{rails_repo_folder} && git pull"
  else
    sh "git clone https://github.com/rails/rails #{rails_repo_folder}"
  end
end