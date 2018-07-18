module Projects
  class UpdateService < BaseService
    include UpdateVisibilityLevel

    def execute
      unless valid_visibility_level_change?(project, params[:visibility_level])
        return error('New visibility level not allowed!')
      end

      if renaming_project_with_container_registry_tags?
        return error('Cannot rename project because it contains container registry tags!')
      end

      if changing_default_branch?
        return error("Could not set the default branch") unless project.change_head(params[:default_branch])
      end

      ensure_wiki_exists if enabling_wiki?

      yield if block_given?

      # If the block added errors, don't try to save the project
      return validation_failed! if project.errors.any?

      if project.update(params.except(:default_branch))
        if project.previous_changes.include?('path')
          project.rename_repo
        else
          system_hook_service.execute_hooks_for(project, :update)
        end

        update_pages_config if changing_pages_https_only?

        success
      else
        validation_failed!
      end
    end

    def run_auto_devops_pipeline?
      return false if project.repository.gitlab_ci_yml || !project.auto_devops&.previous_changes&.include?('enabled')

      project.auto_devops.enabled? || (project.auto_devops.enabled.nil? && Gitlab::CurrentSettings.auto_devops_enabled?)
    end

    private

    def validation_failed!
      model_errors = project.errors.full_messages.to_sentence
      error_message = model_errors.presence || 'Project could not be updated!'

      error(error_message)
    end

    def renaming_project_with_container_registry_tags?
      new_path = params[:path]

      new_path && new_path != project.path &&
        project.has_container_registry_tags?
    end

    def changing_default_branch?
      new_branch = params[:default_branch]

      new_branch && project.repository.exists? &&
        new_branch != project.default_branch
    end

    def enabling_wiki?
      return false if @project.wiki_enabled?

      params.dig(:project_feature_attributes, :wiki_access_level).to_i > ProjectFeature::DISABLED
    end

    def ensure_wiki_exists
      ProjectWiki.new(project, project.owner).wiki
    rescue ProjectWiki::CouldNotCreateWikiError
      log_error("Could not create wiki for #{project.full_name}")
      Gitlab::Metrics.counter(:wiki_can_not_be_created_total, 'Counts the times we failed to create a wiki')
    end

    def update_pages_config
      Projects::UpdatePagesConfigurationService.new(project).execute
    end

    def changing_pages_https_only?
      project.previous_changes.include?(:pages_https_only)
    end
  end
end
