module QA
  describe 'LDAP user login', :ldap do
    before do
      Runtime::Env.user_type = 'ldap'
    end

    it 'user logs in using LDAP credentials' do
      Runtime::Browser.visit(:gitlab, Page::Main::Login)
      Page::Main::Login.act { sign_in_using_credentials }

      # TODO, since `Signed in successfully` message was removed
      # this is the only way to tell if user is signed in correctly.
      #
      Page::Menu::Main.perform do |menu|
        expect(menu).to have_personal_area
      end
    end
  end
end
