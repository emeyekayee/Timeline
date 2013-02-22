require 'fast_git_deploy'
if Capistrano::Configuration.instance
  FastGitDeploy::Deploy.load_into(Capistrano::Configuration.instance)
  FastGitDeploy::Setup.load_into(Capistrano::Configuration.instance)
end
