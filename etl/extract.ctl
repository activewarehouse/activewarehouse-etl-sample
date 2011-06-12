require File.dirname(__FILE__) + '/common'

pre_process do
  if File.exist?(GIT_RAILS_REPO)
    system! "cd #{GIT_RAILS_REPO} && git pull"
  else
    system! "git clone https://github.com/rails/rails #{GIT_RAILS_REPO}"
  end
end