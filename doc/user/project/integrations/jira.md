# GitLab JIRA integration

GitLab can be configured to interact with [JIRA], a project management platform.

Once your GitLab project is connected to JIRA, you can reference and close the
issues in JIRA directly from GitLab.

For a use case, check out this article of [How and why to integrate GitLab with
JIRA](https://www.programmableweb.com/news/how-and-why-to-integrate-gitlab-jira/how-to/2017/04/25).

## Configuration

Each GitLab project can be configured to connect to a different JIRA instance. That
means one GitLab project maps to _all_ JIRA projects in that JIRA instance once
the configuration is set up. Therefore, you don't have to explicitly associate 
one GitLab project to any JIRA project. Once the configuration is set up, any JIRA
projects in the JIRA instance are already mapped to the GitLab project.

If you have one JIRA instance you can pre-fill the settings page with a default
template, see the [Services Templates][services-templates] docs.

Configuration happens via user name and password. Connecting to a JIRA server
via CAS is not possible.

In order to enable the JIRA service in GitLab, you need to first configure the
project in JIRA and then enter the correct values in GitLab.

### Configuring JIRA

We need to create a user in JIRA which will have access to all projects that
need to integrate with GitLab. Login to your JIRA instance as admin and under
Administration go to User Management and create a new user.

As an example, we'll create a user named `gitlab` and add it to `JIRA-developers`
group.

**It is important that the user `GitLab` has write-access to projects in JIRA**

We have split this stage in steps so it is easier to follow.

---

1. Login to your JIRA instance as an administrator and under **Administration**
   go to **User Management** to create a new user.

     ![JIRA user management link](img/jira_user_management_link.png)

     ---

1. The next step is to create a new user (e.g., `gitlab`) who has write access
   to projects in JIRA. Enter the user's name and a _valid_ e-mail address
   since JIRA sends a verification e-mail to set-up the password.
   _**Note:** JIRA creates the username automatically by using the e-mail
   prefix. You can change it later if you want._

     ![JIRA create new user](img/jira_create_new_user.png)

     ---

1. Now, let's create a `gitlab-developers` group which will have write access
   to projects in JIRA. Go to the **Groups** tab and select **Create group**.

     ![JIRA create new user](img/jira_create_new_group.png)

     ---

     Give it an optional description and hit **Create group**.

     ![jira create new group](img/jira_create_new_group_name.png)

     ---

1. Give the newly-created group write access by going to
   **Application access ➔ View configuration** and adding the `gitlab-developers`
   group to JIRA Core.

     ![JIRA group access](img/jira_group_access.png)

     ---

1. Add the `gitlab` user to the `gitlab-developers` group by going to
   **Users ➔ GitLab user ➔ Add group** and selecting the `gitlab-developers`
   group from the dropdown menu. Notice that the group says _Access_ which is
   what we aim for.

     ![JIRA add user to group](img/jira_add_user_to_group.png)

     ---

The JIRA configuration is over. Write down the new JIRA username and its
password as they will be needed when configuring GitLab in the next section.

### Configuring GitLab

>**Notes:**
- The currently supported JIRA versions are `v6.x` and `v7.x.`. GitLab 7.8 or
  higher is required.
- GitLab 8.14 introduced a new way to integrate with JIRA which greatly simplified
  the configuration options you have to enter. If you are using an older version,
  [follow this documentation][jira-repo-old-docs].
- In order to support Oracle's Access Manager, GitLab will send additional cookies
  to enable Basic Auth. The cookie being added to each request is `OBBasicAuth` with
  a value of `fromDialog`.

To enable JIRA integration in a project, navigate to the
[Integrations page](project_services.md#accessing-the-project-services), click
the **JIRA** service, and fill in the required details on the page as described
in the table below.

| Field | Description |
| ----- | ----------- |
| `Web URL` | The base URL to the JIRA instance web interface which is being linked to this GitLab project. E.g., `https://jira.example.com`. |
| `JIRA API URL` | The base URL to the JIRA instance API. Web URL value will be used if not set. E.g., `https://jira-api.example.com`. |
| `Username` | The user name created in [configuring JIRA step](#configuring-jira). Using the email address will cause `401 unauthorized`. |
| `Password` |The password of the user created in [configuring JIRA step](#configuring-jira). |
| `Transition ID` | This is the ID of a transition that moves issues to the desired state.  **Closing JIRA issues via commits or Merge Requests won't work if you don't set the ID correctly.** |

### Getting a transition ID

In the most recent JIRA UI, you can no longer see transition IDs in the workflow
administration UI. You can get the ID you need in either of the following ways:

1. By using the API, with a request like `https://yourcompany.atlassian.net/rest/api/2/issue/ISSUE-123/transitions`
   using an issue that is in the appropriate "open" state
1. By mousing over the link for the transition you want and looking for the
   "action" parameter in the URL

Note that the transition ID may vary between workflows (e.g., bug vs. story),
even if the status you are changing to is the same.

After saving the configuration, your GitLab project will be able to interact
with all JIRA projects in your JIRA instance and you'll see the JIRA link on the GitLab project pages that takes you to the appropriate JIRA project.

![JIRA service page](img/jira_service_page.png)

---

## JIRA issues

By now you should have [configured JIRA](#configuring-jira) and enabled the
[JIRA service in GitLab](#configuring-gitlab). If everything is set up correctly
you should be able to reference and close JIRA issues by just mentioning their
ID in GitLab commits and merge requests.

### Referencing JIRA Issues

When GitLab project has JIRA issue tracker configured and enabled, mentioning
JIRA issue in GitLab will automatically add a comment in JIRA issue with the
link back to GitLab. This means that in comments in merge requests and commits
referencing an issue, e.g., `PROJECT-7`, will add a comment in JIRA issue in the
format:

```
USER mentioned this issue in RESOURCE_NAME of [PROJECT_NAME|LINK_TO_COMMENT]:
ENTITY_TITLE
```

* `USER` A user that mentioned the issue. This is the link to the user profile in GitLab.
* `LINK_TO_THE_COMMENT` Link to the origin of mention with a name of the entity where JIRA issue was mentioned.
* `RESOURCE_NAME` Kind of resource which referenced the issue. Can be a commit or merge request.
* `PROJECT_NAME` GitLab project name.
* `ENTITY_TITLE` Merge request title or commit message first line.

![example of mentioning or closing the JIRA issue](img/jira_issue_reference.png)

---

### Closing JIRA Issues

JIRA issues can be closed directly from GitLab by using trigger words in
commits and merge requests. When a commit which contains the trigger word
followed by the JIRA issue ID in the commit message is pushed, GitLab will
add a comment in the mentioned JIRA issue and immediately close it (provided
the transition ID was set up correctly).

There are currently three trigger words, and you can use either one to achieve
the same goal:

- `Resolves PROJECT-1`
- `Closes PROJECT-1`
- `Fixes PROJECT-1`

where `PROJECT-1` is the issue ID of the JIRA project.

>**Note:**
- Only commits and merges into the project's default branch (usually **master**) will
  close an issue in Jira. You can change your projects default branch under
  [project settings](img/jira_project_settings.png).
- The JIRA issue will not be transitioned if it has a resolution.

### JIRA issue closing example

Let's consider the following example:

1. For the project named `PROJECT` in JIRA, we implemented a new feature
   and created a merge request in GitLab.
1. This feature was requested in JIRA issue `PROJECT-7` and the merge request
   in GitLab contains the improvement
1. In the merge request description we use the issue closing trigger
   `Closes PROJECT-7`.
1. Once the merge request is merged, the JIRA issue will be automatically closed
   with a comment and an associated link to the commit that resolved the issue.

---

In the following screenshot you can see what the link references to the JIRA
issue look like.

![A Git commit that causes the JIRA issue to be closed](img/jira_merge_request_close.png)

---

Once this merge request is merged, the JIRA issue will be automatically closed
with a link to the commit that resolved the issue.

![The GitLab integration closes JIRA issue](img/jira_service_close_issue.png)

---

![The GitLab integration creates a comment and a link on JIRA issue.](img/jira_service_close_comment.png)

## Troubleshooting

If things don't work as expected that's usually because you have configured
incorrectly the JIRA-GitLab integration.

### GitLab is unable to comment on a ticket

Make sure that the user you set up for GitLab to communicate with JIRA has the
correct access permission to post comments on a ticket and to also transition
the ticket, if you'd like GitLab to also take care of closing them.
JIRA issue references and update comments will not work if the GitLab issue tracker is disabled.

### GitLab is unable to close a ticket

Make sure the `Transition ID` you set within the JIRA settings matches the one
your project needs to close a ticket.

Make sure that the JIRA issue is not already marked as resolved, in other words that
the JIRA issue resolution field is not set. (It should not be struck through in
JIRA lists.)

[services-templates]: services_templates.md
[jira-repo-old-docs]: https://gitlab.com/gitlab-org/gitlab-ce/blob/8-13-stable/doc/project_services/jira.md
[jira]: https://www.atlassian.com/software/jira
