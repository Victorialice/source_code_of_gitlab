# Web IDE

> [Introduced in](https://gitlab.com/gitlab-org/gitlab-ee/issues/4539) [GitLab Ultimate][ee] 10.4.
> [Brought to GitLab Core](https://gitlab.com/gitlab-org/gitlab-ce/issues/44157) in 10.7.

The Web IDE makes it faster and easier to contribute changes to your projects
by providing an advanced editor with commit staging.

## Open the Web IDE

The Web IDE can be opened when viewing a file, from the repository file list,
and from merge requests.

![Open Web IDE](img/open_web_ide.png)

## File finder

> [Introduced in](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/18323) [GitLab Core][ce] 10.8.

The file finder allows you to quickly open files in the current branch by
searching. The file finder is launched using the keyboard shortcut `Command-p`,
`Control-p`, or `t` (when editor is not in focus). Type the filename or
file path fragments to start seeing results.

## Stage and commit changes

After making your changes, click the Commit button in the bottom left to
review the list of changed files. Click on each file to review the changes and
click the tick icon to stage the file. 

Once you have staged some changes, you can add a commit message and commit the
staged changes. Unstaged changes will not be commited.

![Commit changes](img/commit_changes.png)

## Reviewing changes

Before you commit your changes, you can compare them with the previous commit
by switching to the review mode or selecting the file from the staged files
list.

An additional review mode is available when you open a merge request, which
shows you a preview of the merge request diff if you commit your changes.

## View CI job logs

> [Introduced in](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/19279) [GitLab Core][ce] 11.0.

The Web IDE can be used to quickly fix failing tests by opening the branch or
merge request in the Web IDE and opening the logs of the failed job. The status
of all jobs for the most recent pipeline and job traces for the current commit
can be accessed by clicking the **Pipelines** button in the top right.

The pipeline status is also shown at all times in the status bar in the bottom
left.

## Switching merge requests

> [Introduced in](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/19318) [GitLab Core][ce] 11.0.

Switching between your authored and assigned merge requests can be done without
leaving the Web IDE. Click the project name in the top left to open a list of
merge requests. You will need to commit or discard all your changes before
switching to a different merge request.

[ce]: https://about.gitlab.com/pricing/
[ee]: https://about.gitlab.com/pricing/
