module Commits
  class CherryPickService < ChangeService
    def create_commit!
      commit_change(:cherry_pick)
    end
  end
end
