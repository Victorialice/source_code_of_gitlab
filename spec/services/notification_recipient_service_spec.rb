require 'spec_helper'

describe NotificationRecipientService do
  let(:service) { described_class }
  let(:assignee) { create(:user) }
  let(:project) { create(:project, :public) }
  let(:other_projects) { create_list(:project, 5, :public) }

  describe '#build_new_note_recipients' do
    let(:issue) { create(:issue, project: project, assignees: [assignee]) }
    let(:note) { create(:note_on_issue, noteable: issue, project_id: issue.project_id) }

    def create_watcher
      watcher = create(:user)
      create(:notification_setting, source: project, user: watcher, level: :watch)

      other_projects.each do |other_project|
        create(:notification_setting, source: other_project, user: watcher, level: :watch)
      end
    end

    it 'avoids N+1 queries', :request_store do
      create_watcher

      service.build_new_note_recipients(note)

      control_count = ActiveRecord::QueryRecorder.new do
        service.build_new_note_recipients(note)
      end

      create_watcher

      expect { service.build_new_note_recipients(note) }.not_to exceed_query_limit(control_count)
    end
  end
end
