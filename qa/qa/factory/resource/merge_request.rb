require 'securerandom'

module QA
  module Factory
    module Resource
      class MergeRequest < Factory::Base
        attr_accessor :title,
                      :description,
                      :source_branch,
                      :target_branch,
                      :assignee,
                      :milestone,
                      :labels

        product :project do |factory|
          factory.project
        end

        product :source_branch do |factory|
          factory.source_branch
        end

        dependency Factory::Resource::Project, as: :project do |project|
          project.name = 'project-with-merge-request'
        end

        dependency Factory::Repository::ProjectPush, as: :target do |push, factory|
          factory.project.visit!
          push.project = factory.project
          push.branch_name = 'master'
          push.remote_branch = factory.target_branch
        end

        dependency Factory::Repository::ProjectPush, as: :source do |push, factory|
          push.project = factory.project
          push.branch_name = factory.target_branch
          push.remote_branch = factory.source_branch
          push.file_name = "added_file.txt"
          push.file_content = "File Added"
        end

        def initialize
          @title = 'QA test - merge request'
          @description = 'This is a test merge request'
          @source_branch = "qa-test-feature-#{SecureRandom.hex(8)}"
          @target_branch = "master"
          @assignee = nil
          @milestone = nil
          @labels = []
        end

        def fabricate!
          project.visit!
          Page::Project::Show.act { new_merge_request }
          Page::MergeRequest::New.perform do |page|
            page.fill_title(@title)
            page.fill_description(@description)
            page.choose_milestone(@milestone) if @milestone
            page.create_merge_request
          end
        end
      end
    end
  end
end
