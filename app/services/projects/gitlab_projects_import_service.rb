# This service is an adapter used to for the GitLab Import feature, and
# creating a project from a template.
# The latter will under the hood just import an archive supplied by GitLab.
module Projects
  class GitlabProjectsImportService
    attr_reader :current_user, :params

    def initialize(user, import_params, override_params = nil)
      @current_user, @params, @override_params = user, import_params.dup, override_params
    end

    def execute
      FileUtils.mkdir_p(File.dirname(import_upload_path))

      file = params.delete(:file)
      FileUtils.copy_entry(file.path, import_upload_path)

      @overwrite = params.delete(:overwrite)
      data = {}
      data[:override_params] = @override_params if @override_params

      if overwrite_project?
        data[:original_path] = params[:path]
        params[:path] += "-#{tmp_filename}"
      end

      params[:import_type] = 'gitlab_project'
      params[:import_source] = import_upload_path
      params[:import_data] = { data: data } if data.present?

      ::Projects::CreateService.new(current_user, params).execute
    end

    private

    def import_upload_path
      @import_upload_path ||= Gitlab::ImportExport.import_upload_path(filename: tmp_filename)
    end

    def tmp_filename
      SecureRandom.hex
    end

    def overwrite_project?
      @overwrite && project_with_same_full_path?
    end

    def project_with_same_full_path?
      Project.find_by_full_path("#{current_namespace.full_path}/#{params[:path]}").present?
    end

    def current_namespace
      @current_namespace ||= Namespace.find_by(id: params[:namespace_id])
    end
  end
end
