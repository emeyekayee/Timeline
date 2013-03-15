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

set :normalize_asset_timestamps, false # task :finalize_update failing from
                                       # images, etc not being under .../public
set :public_children, []               # Yes, this is overkill.

# require 'ripl'
# Ripl.start binding: binding

after "deploy:update_code" do  
  run "cd #{release_path}/config && ln -nfs #{shared_path}/config/database.yml ."
end

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

# namespace :deploy do
#   task :create_symlink do; end
# end


# Customization --mjc

set :from_db_host, 'cannon@mjc3'
set :dump_file,    '/tmp/mythconverg.sql.gz'
set :dcmd,         "mysqldump -u mythtv -pXdl5bjo6 mythconverg | " +
                   "gzip - >#{dump_file}"
set :prod_db_host, 'ubuntu@prod1.emeyekayee.com'

desc <<-DESC
  Dump the local database for export to production database.
DESC
task :dump_source_db, hosts: from_db_host do
  `ssh #{from_db_host} "#{dcmd}"`
  puts "The mysqldump completed with exit code #{$?}"

  `scp -p #{from_db_host}:#{dump_file} #{dump_file}`
  puts "Local copy completed with exit code #{$?}"
end


desc <<-DESC
  Send the local database dump to production database.
DESC
task :update_mythconverg_db do # , :roles => :mysql_master

  `scp -i ~/.ec2/gpg-keypair #{dump_file} #{prod_db_host}:#{dump_file}`

  `ssh -i ~/.ec2/gpg-keypair #{prod_db_host} "zcat #{dump_file} | mysql -u root mythconverg"`

end

before "update_mythconverg_db", "dump_source_db"
