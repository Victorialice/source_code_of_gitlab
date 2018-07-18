# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RenameMergeRequestsAllowCollaboration < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if column_exists?(:merge_requests, :allow_collaboration)
      rename_column_concurrently :merge_requests, :allow_collaboration, :allow_maintainer_to_push
    end
  end

  def down
    # NOOP
  end
end
