module Gitlab
  class UsageData
    class << self
      def data(force_refresh: false)
        Rails.cache.fetch('usage_data', force: force_refresh, expires_in: 2.weeks) { uncached_data }
      end

      def uncached_data
        license_usage_data.merge(system_usage_data)
                          .merge(features_usage_data)
                          .merge(components_usage_data)
                          .merge(cycle_analytics_usage_data)
      end

      def to_json(force_refresh: false)
        data(force_refresh: force_refresh).to_json
      end

      def license_usage_data
        usage_data = {
          uuid: Gitlab::CurrentSettings.uuid,
          hostname: Gitlab.config.gitlab.host,
          version: Gitlab::VERSION,
          installation_type: Gitlab::INSTALLATION_TYPE,
          active_user_count: User.active.count,
          recorded_at: Time.now,
          edition: 'CE'
        }

        usage_data
      end

      # rubocop:disable Metrics/AbcSize
      def system_usage_data
        {
          counts: {
            boards: Board.count,
            ci_builds: ::Ci::Build.count,
            ci_internal_pipelines: ::Ci::Pipeline.internal.count,
            ci_external_pipelines: ::Ci::Pipeline.external.count,
            ci_pipeline_config_auto_devops: ::Ci::Pipeline.auto_devops_source.count,
            ci_pipeline_config_repository: ::Ci::Pipeline.repository_source.count,
            ci_runners: ::Ci::Runner.count,
            ci_triggers: ::Ci::Trigger.count,
            ci_pipeline_schedules: ::Ci::PipelineSchedule.count,
            auto_devops_enabled: ::ProjectAutoDevops.enabled.count,
            auto_devops_disabled: ::ProjectAutoDevops.disabled.count,
            deploy_keys: DeployKey.count,
            deployments: Deployment.count,
            environments: ::Environment.count,
            clusters: ::Clusters::Cluster.count,
            clusters_enabled: ::Clusters::Cluster.enabled.count,
            clusters_disabled: ::Clusters::Cluster.disabled.count,
            clusters_platforms_gke: ::Clusters::Cluster.gcp_installed.enabled.count,
            clusters_platforms_user: ::Clusters::Cluster.user_provided.enabled.count,
            clusters_applications_helm: ::Clusters::Applications::Helm.installed.count,
            clusters_applications_ingress: ::Clusters::Applications::Ingress.installed.count,
            clusters_applications_prometheus: ::Clusters::Applications::Prometheus.installed.count,
            clusters_applications_runner: ::Clusters::Applications::Runner.installed.count,
            in_review_folder: ::Environment.in_review_folder.count,
            groups: Group.count,
            issues: Issue.count,
            keys: Key.count,
            labels: Label.count,
            lfs_objects: LfsObject.count,
            merge_requests: MergeRequest.count,
            milestones: Milestone.count,
            notes: Note.count,
            pages_domains: PagesDomain.count,
            projects: Project.count,
            projects_imported_from_github: Project.where(import_type: 'github').count,
            protected_branches: ProtectedBranch.count,
            releases: Release.count,
            remote_mirrors: RemoteMirror.count,
            snippets: Snippet.count,
            todos: Todo.count,
            uploads: Upload.count,
            web_hooks: WebHook.count
          }.merge(services_usage)
        }
      end

      def cycle_analytics_usage_data
        Gitlab::CycleAnalytics::UsageData.new.to_json
      end

      def features_usage_data
        features_usage_data_ce
      end

      def features_usage_data_ce
        {
          container_registry_enabled: Gitlab.config.registry.enabled,
          gitlab_shared_runners_enabled: Gitlab.config.gitlab_ci.shared_runners_enabled,
          gravatar_enabled: Gitlab::CurrentSettings.gravatar_enabled?,
          ldap_enabled: Gitlab.config.ldap.enabled,
          mattermost_enabled: Gitlab.config.mattermost.enabled,
          omniauth_enabled: Gitlab.config.omniauth.enabled,
          reply_by_email_enabled: Gitlab::IncomingEmail.enabled?,
          signup_enabled: Gitlab::CurrentSettings.allow_signup?
        }
      end

      def components_usage_data
        {
          gitlab_pages: { enabled: Gitlab.config.pages.enabled, version: Gitlab::Pages::VERSION },
          git: { version: Gitlab::Git.version },
          database: { adapter: Gitlab::Database.adapter_name, version: Gitlab::Database.version }
        }
      end

      def services_usage
        types = {
          JiraService: :projects_jira_active,
          SlackService: :projects_slack_notifications_active,
          SlackSlashCommandsService: :projects_slack_slash_active,
          PrometheusService: :projects_prometheus_active
        }

        results = Service.unscoped.where(type: types.keys, active: true).group(:type).count
        results.each_with_object({}) { |(key, value), response| response[types[key.to_sym]] = value  }
      end
    end
  end
end
