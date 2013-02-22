require "bundler/capistrano"
# require 'fast_git_deploy/enable'

set :application, "tvg"
set :repository,  "https://github.com/emeyekayee/Timeline.git"

set :user, "ubuntu"
set :use_sudo, false
set :deploy_type, :deploy
set :branch, "AWS-chef-deploy"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
# ssh_options[:keys] = [File.join(ENV["HOME"], ".vagrant.d", "insecure_private_key")]
ssh_options[:keys] = [File.expand_path('~/.ec2/gpg-keypair')]

role :app, "tvg.test"
role :web, "tvg.test"
role :db,  "tvg.test", :primary => true

after "deploy:setup" do
  deploy.fast_git_setup.clone_repository
  run "cd #{current_path} && bundle install"
end

namespace :unicorn do
  desc "Start unicorn for this application"
  task :start do
    run "cd #{current_path} && bundle exec unicorn -c /etc/unicorn/tvg.conf.rb -D"
  end
end

namespace :deploy do
  task :create_symlink do; end
end
