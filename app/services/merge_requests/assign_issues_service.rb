module MergeRequests
  class AssignIssuesService < BaseService
    def assignable_issues
      @assignable_issues ||= begin
        if current_user == merge_request.author
          closes_issues.select do |issue|
            !issue.is_a?(ExternalIssue) && !issue.assignees.present? && can?(current_user, :admin_issue, issue)
          end
        else
          []
        end
      end
    end

    def execute
      assignable_issues.each do |issue|
        Issues::UpdateService.new(issue.project, current_user, assignee_ids: [current_user.id]).execute(issue)
      end

      {
        count: assignable_issues.count
      }
    end

    private

    def merge_request
      params[:merge_request]
    end

    def closes_issues
      @closes_issues ||= params[:closes_issues] || merge_request.closes_issues(current_user)
    end
  end
end
