module ProtectedTags
  class CreateService < BaseService
    attr_reader :protected_tag

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :admin_project, project)

      project.protected_tags.create(params)
    end
  end
end
