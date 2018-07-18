module Boards
  module Issues
    class ListService < Boards::BaseService
      def execute
        issues = IssuesFinder.new(current_user, filter_params).execute
        issues = filter(issues)
        issues.order_by_position_and_priority
      end

      private

      def filter(issues)
        issues = without_board_labels(issues) unless list&.movable? || list&.closed?
        issues = with_list_label(issues) if list&.label?
        issues
      end

      def board
        @board ||= parent.boards.find(params[:board_id])
      end

      def list
        return @list if defined?(@list)

        @list = board.lists.find(params[:id]) if params.key?(:id)
      end

      def filter_params
        set_parent
        set_state
        set_scope

        params
      end

      def set_parent
        if parent.is_a?(Group)
          params[:group_id] = parent.id
        else
          params[:project_id] = parent.id
        end
      end

      def set_state
        params[:state] = list && list.closed? ? 'closed' : 'opened'
      end

      def set_scope
        params[:include_subgroups] = board.group_board?
      end

      def board_label_ids
        @board_label_ids ||= board.lists.movable.pluck(:label_id)
      end

      def without_board_labels(issues)
        return issues unless board_label_ids.any?

        issues.where.not('EXISTS (?)', issues_label_links.limit(1))
      end

      def issues_label_links
        LabelLink.where("label_links.target_type = 'Issue' AND label_links.target_id = issues.id").where(label_id: board_label_ids)
      end

      def with_list_label(issues)
        issues.where('EXISTS (?)', LabelLink.where("label_links.target_type = 'Issue' AND label_links.target_id = issues.id")
                                            .where("label_links.label_id = ?", list.label_id).limit(1))
      end
    end
  end
end
