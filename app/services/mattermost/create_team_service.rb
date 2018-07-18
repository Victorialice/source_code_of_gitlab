module Mattermost
  class CreateTeamService < ::BaseService
    def initialize(group, current_user)
      @group, @current_user = group, current_user
    end

    def execute
      # The user that creates the team will be Team Admin
      Mattermost::Team.new(current_user).create(@group.mattermost_team_params)
    rescue Mattermost::ClientError => e
      @group.errors.add(:mattermost_team, e.message)
    end
  end
end
