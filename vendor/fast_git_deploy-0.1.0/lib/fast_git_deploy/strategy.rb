require 'capistrano/recipes/deploy/strategy/remote'

module FastGitDeploy
  class Strategy < Capistrano::Deploy::Strategy::Remote
    def checkout!(path = configuration[:current_path])
      scm_run "#{source.checkout(revision, path)} && #{mark(revision, path)}"
    end

    def rollback!
      if previous_revision
        scm_run("#{source.sync(previous_revision, configuration[:current_path])} && #{mark(previous_revision)}")
      else
        raise(Capistrano::Error, "Couldn't find a revision previous to #{current_revision}")
      end
    end

    def command
      @command ||= source.sync(revision, configuration[:current_path])
    end

    def mark(rev = revision, path = configuration[:current_path])
      "(echo #{rev} > #{path}/REVISION) && #{revision_log_mark(rev)}"
    end

    def revision_log_mark(rev = revision)
      "(echo `date +\"%Y-%m-%d %H:%M:%S\"` $USER #{rev} >> #{revision_log})"
    end
  end
end

module Capistrano
  module Deploy
    module Strategy
      FastGitDeploy = ::FastGitDeploy::Strategy
    end
  end
end