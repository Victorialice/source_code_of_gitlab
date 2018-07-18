# rubocop:disable all
class MigrateToNewShell < ActiveRecord::Migration
  def change
    return if Rails.env.test? || Rails.env.development?

    gitlab_shell_path = Gitlab.config.gitlab_shell.path
    if system("#{gitlab_shell_path}/bin/create-hooks")
      puts 'Repositories updated with new hooks'
    else
      raise 'Failed to rewrite gitlab-shell hooks in repositories'
    end
  end
end
