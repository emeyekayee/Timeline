
set :application, "fast_git_deploy_test"
set :repository,  File.expand_path('../../../.git', __FILE__)
set :deploy_to,   File.expand_path('../../deployments', __FILE__)
set :scm,         :git

unless fetch(:disable_fast_git_deploy, false)
  require 'fast_git_deploy/enable'
end

set :use_sudo,    false
set :user,        ENV['USER']
set(:password)    { Capistrano::CLI.password_prompt("SSH password for #{user}@localhost: ") }

ssh_options[:paranoid] = false
default_run_options[:pty] = true

role :web, "127.0.0.1"
role :app, "127.0.0.1"
role :db,  "127.0.0.1", :primary => true

set :branch, "master"

namespace :deploy do
  task :restart do
    # do nothing
  end

  task :migrate do
    # do nothing
  end

  task :start do
    # do nothing
  end
end