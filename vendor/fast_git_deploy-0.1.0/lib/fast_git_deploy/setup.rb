module FastGitDeploy
  module Setup
    def self.load_into(configuration)
      configuration.load do
        namespace :fast_git_setup do
          task :cold do
            strategy.checkout!
            deploy.update
            deploy.restart
          end

          task :warm do
            clone_repository_to_tmp_path

            deploy.web.disable
            remove_old_app
            rename_clone

            deploy.update
            deploy.restart
            deploy.web.enable
          end

          task :clone_repository_to_tmp_path, :except => { :no_release => true } do
            strategy.checkout!("#{current_path}.clone")
          end

          task :rename_clone, :except => { :no_release => true } do
            run "mv #{current_path}.clone #{current_path}"
          end

          task :remove_old_app do
            remove_releases
            remove_current
          end

          task :remove_releases, :except => { :no_release => true } do
            run [
              "if [ -e #{deploy_to}/releases ]",
                "then mv #{deploy_to}/releases #{deploy_to}/releases.old",
              "fi"
            ].join("; ")
          end

          task :remove_current, :except => { :no_release => true } do
            # test -h => symlink
            run [
              "if [ -h #{current_path} ]",
                "then mv #{current_path} #{current_path}.old",
              "fi"
            ].join("; ")
          end
        end
      end
    end
  end
end