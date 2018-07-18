class EnvironmentPolicy < BasePolicy
  delegate { @subject.project }

  condition(:stop_with_deployment_allowed) do
    @subject.stop_action? && can?(:create_deployment) && can?(:update_build, @subject.stop_action)
  end

  condition(:stop_with_update_allowed) do
    !@subject.stop_action? && can?(:update_environment, @subject)
  end

  rule { stop_with_deployment_allowed | stop_with_update_allowed }.enable :stop_environment
end
