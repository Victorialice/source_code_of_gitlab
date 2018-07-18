module QA
  describe 'push code to repository', :core do
    context 'with regular account over http' do
      it 'user pushes code to the repository'  do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        Factory::Repository::ProjectPush.fabricate! do |push|
          push.file_name = 'README.md'
          push.file_content = '# This is a test project'
          push.commit_message = 'Add README.md'
        end

        Page::Project::Show.act { wait_for_push }

        expect(page).to have_content('README.md')
        expect(page).to have_content('This is a test project')
      end
    end
  end
end
