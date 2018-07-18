require "spec_helper"

describe "User creates wiki page" do
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)

    visit(project_wikis_path(project))
    click_link "Create your first page"
  end

  context "when wiki is empty" do
    context "in a user namespace" do
      let(:project) { create(:project, :wiki_repo, namespace: user.namespace) }

      it "shows validation error message" do
        page.within(".wiki-form") do
          fill_in(:wiki_content, with: "")

          click_on("Create page")
        end

        expect(page).to have_content("The form contains the following error:").and have_content("Content can't be blank")

        page.within(".wiki-form") do
          fill_in(:wiki_content, with: "[link test](test)")

          click_on("Create page")
        end

        expect(page).to have_content("Home").and have_content("link test")

        click_link("link test")

        expect(page).to have_content("Create Page")
      end

      it "shows non-escaped link in the pages list", :js do
        click_link("New page")

        page.within("#modal-new-wiki") do
          fill_in(:new_wiki_path, with: "one/two/three-test")

          click_on("Create page")
        end

        page.within(".wiki-form") do
          fill_in(:wiki_content, with: "wiki content")

          click_on("Create page")
        end

        expect(current_path).to include("one/two/three-test")
        expect(page).to have_xpath("//a[@href='/#{project.full_path}/wikis/one/two/three-test']")
      end

      it "has `Create home` as a commit message" do
        expect(page).to have_field("wiki[message]", with: "Create home")
      end

      it "creates a page from the home page" do
        fill_in(:wiki_content, with: "[test](test)\n[GitLab API doc](api)\n[Rake tasks](raketasks)\n# Wiki header\n")
        fill_in(:wiki_message, with: "Adding links to wiki")

        page.within(".wiki-form") do
          click_button("Create page")
        end

        expect(current_path).to eq(project_wiki_path(project, "home"))
        expect(page).to have_content("test GitLab API doc Rake tasks Wiki header")
                   .and have_content("Home")
                   .and have_content("Last edited by #{user.name}")
                   .and have_header_with_correct_id_and_link(1, "Wiki header", "wiki-header")

        click_link("test")

        expect(current_path).to eq(project_wiki_path(project, "test"))

        page.within(:css, ".nav-text") do
          expect(page).to have_content("Test").and have_content("Create Page")
        end

        click_link("Home")

        expect(current_path).to eq(project_wiki_path(project, "home"))

        click_link("GitLab API")

        expect(current_path).to eq(project_wiki_path(project, "api"))

        page.within(:css, ".nav-text") do
          expect(page).to have_content("Create").and have_content("Api")
        end

        click_link("Home")

        expect(current_path).to eq(project_wiki_path(project, "home"))

        click_link("Rake tasks")

        expect(current_path).to eq(project_wiki_path(project, "raketasks"))

        page.within(:css, ".nav-text") do
          expect(page).to have_content("Create").and have_content("Rake")
        end
      end

      it "creates ASCII wiki with LaTeX blocks", :js do
        stub_application_setting(plantuml_url: "http://localhost", plantuml_enabled: true)

        ascii_content = <<~MD
          :stem: latexmath

          [stem]
          ++++
          \\sqrt{4} = 2
          ++++

          another part

          [latexmath]
          ++++
          \\beta_x \\gamma
          ++++

          stem:[2+2] is 4
        MD

        find("#wiki_format option[value=asciidoc]").select_option

        fill_in(:wiki_content, with: ascii_content)

        page.within(".wiki-form") do
          click_button("Create page")
        end

        page.within ".wiki" do
          expect(page).to have_selector(".katex", count: 3).and have_content("2+2 is 4")
        end
      end
    end

    context "in a group namespace", :js do
      let(:project) { create(:project, :wiki_repo, namespace: create(:group, :public)) }

      it "has `Create home` as a commit message" do
        expect(page).to have_field("wiki[message]", with: "Create home")
      end

      it "creates a page from from the home page" do
        page.within(".wiki-form") do
          fill_in(:wiki_content, with: "My awesome wiki!")

          click_button("Create page")
        end

        expect(page).to have_content("Home")
                   .and have_content("Last edited by #{user.name}")
                   .and have_content("My awesome wiki!")
      end
    end
  end

  context "when wiki is not empty", :js do
    before do
      create(:wiki_page, wiki: create(:project, :wiki_repo, namespace: user.namespace).wiki, attrs: { title: "home", content: "Home page" })
    end

    context "in a user namespace" do
      let(:project) { create(:project, :wiki_repo, namespace: user.namespace) }

      context "via the `new wiki page` page" do
        it "creates a page with a single word" do
          click_link("New page")

          page.within("#modal-new-wiki") do
            fill_in(:new_wiki_path, with: "foo")

            click_button("Create page")
          end

          # Commit message field should have correct value.
          expect(page).to have_field("wiki[message]", with: "Create foo")

          page.within(".wiki-form") do
            fill_in(:wiki_content, with: "My awesome wiki!")

            click_button("Create page")
          end

          expect(page).to have_content("Foo")
                     .and have_content("Last edited by #{user.name}")
                     .and have_content("My awesome wiki!")
        end

        it "creates a page with spaces in the name" do
          click_link("New page")

          page.within("#modal-new-wiki") do
            fill_in(:new_wiki_path, with: "Spaces in the name")

            click_button("Create page")
          end

          # Commit message field should have correct value.
          expect(page).to have_field("wiki[message]", with: "Create spaces in the name")

          page.within(".wiki-form") do
            fill_in(:wiki_content, with: "My awesome wiki!")

            click_button("Create page")
          end

          expect(page).to have_content("Spaces in the name")
                     .and have_content("Last edited by #{user.name}")
                     .and have_content("My awesome wiki!")
        end

        it "creates a page with hyphens in the name" do
          click_link("New page")

          page.within("#modal-new-wiki") do
            fill_in(:new_wiki_path, with: "hyphens-in-the-name")

            click_button("Create page")
          end

          # Commit message field should have correct value.
          expect(page).to have_field("wiki[message]", with: "Create hyphens in the name")

          page.within(".wiki-form") do
            fill_in(:wiki_content, with: "My awesome wiki!")

            click_button("Create page")
          end

          expect(page).to have_content("Hyphens in the name")
                     .and have_content("Last edited by #{user.name}")
                     .and have_content("My awesome wiki!")
        end
      end

      it "shows the emoji autocompletion dropdown" do
        click_link("New page")

        page.within("#modal-new-wiki") do
          fill_in(:new_wiki_path, with: "test-autocomplete")

          click_button("Create page")
        end

        page.within(".wiki-form") do
          find("#wiki_content").native.send_keys("")

          fill_in(:wiki_content, with: ":")
        end

        expect(page).to have_selector(".atwho-view")
      end
    end

    context "in a group namespace" do
      let(:project) { create(:project, :wiki_repo, namespace: create(:group, :public)) }

      context "via the `new wiki page` page" do
        it "creates a page" do
          click_link("New page")

          page.within("#modal-new-wiki") do
            fill_in(:new_wiki_path, with: "foo")

            click_button("Create page")
          end

          # Commit message field should have correct value.
          expect(page).to have_field("wiki[message]", with: "Create foo")

          page.within(".wiki-form") do
            fill_in(:wiki_content, with: "My awesome wiki!")

            click_button("Create page")
          end

          expect(page).to have_content("Foo")
                     .and have_content("Last edited by #{user.name}")
                     .and have_content("My awesome wiki!")
        end
      end
    end
  end
end
