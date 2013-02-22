# Make sure we're running in bundler
unless ENV['BUNDLE_BIN_PATH']
  begin
    exec 'bundle', 'exec', $0, *ARGV
  rescue Errno::ENOENT
    puts "Error: Could not run bundler. Install it with `gem install bundler`."
    exit(1)
  end
end

require 'capistrano/cli'
require 'capistrano/configuration'
require 'fileutils'


Spec::Runner.configure do |config|
  config.before :each do
    FileUtils.rm_rf(File.expand_path('../deployments', __FILE__))
  end

  config.after :each do
    FileUtils.rm_rf(File.expand_path('../deployments', __FILE__))
  end
end
