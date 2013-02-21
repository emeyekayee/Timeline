require "spec_helper"

describe "fast git deploy" do
  def cap_execute(command)
    commands = [
      "--file", File.expand_path("../Capfile", __FILE__),
      "--quiet"
    ]
    commands.push command.split(" ")
    commands.flatten!

    Capistrano::CLI.parse(commands).execute!
  end

  it "should be able to deploy with a dry-run" do
    cap_execute "-n deploy"
  end

  it "should be able to deploy:setup" do
    cap_execute "deploy:setup"
  end

  it "should be able to deploy:cold after deploy:setup" do
    cap_execute "deploy:setup"
    cap_execute "deploy:cold"
  end

  it "should be able to deploy" do
    cap_execute "deploy:setup"
    cap_execute "deploy:cold"
    cap_execute "deploy"
  end

  it "should be able to deploy:migrations" do
    cap_execute "deploy:setup"
    cap_execute "deploy:cold"
    cap_execute "deploy:migrations"
  end

  it "should be able to upgrade via deploy:warm" do
    cap_execute "deploy:setup -S disable_fast_git_deploy=true"
    cap_execute "deploy:cold -S disable_fast_git_deploy=true"
    cap_execute "deploy:warm"
  end
end