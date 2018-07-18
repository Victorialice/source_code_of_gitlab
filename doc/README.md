---
comments: false
description: 'Learn how to use and administer GitLab, the most scalable Git-based fully integrated platform for software development.'
---

# GitLab Documentation

Welcome to [GitLab](https://about.gitlab.com/), a Git-based fully featured
platform for software development!

GitLab offers the most scalable Git-based fully integrated platform for
software development, with flexible products and subscriptions.
To understand what features you have access to, check the [GitLab subscriptions](#gitlab-subscriptions) below.

**Shortcuts to GitLab's most visited docs:**

| General documentation | GitLab CI/CD docs |
| :----- | :----- |
| [User documentation](user/index.md) | [GitLab CI/CD quick start guide](ci/quick_start/README.md) |
| [Administrator documentation](administration/index.md) | [GitLab CI/CD examples](ci/examples/README.md) |
| [Contributor documentation](#contributor-documentation) | [Configuring `.gitlab-ci.yml`](ci/yaml/README.md) |
| [Getting started with GitLab](#getting-started-with-gitlab) | [Using Docker images](ci/docker/using_docker_images.md) |
| [API](api/README.md) | [Auto DevOps](topics/autodevops/index.md) |
| [SSH authentication](ssh/README.md) | [Kubernetes integration](user/project/clusters/index.md)|
| [GitLab Pages](user/project/pages/index.md) | [GitLab Container Registry](user/project/container_registry.md) |

## Complete DevOps with GitLab

GitLab is the first single application for software development, security,
and operations that enables Concurrent DevOps, making the software lifecycle
three times faster and radically improving the speed of business. GitLab
provides solutions for all the stages of the DevOps lifecycle:
[plan](#plan), [create](#create), [verify](#verify), [package](#package),
[release](#release), [configure](#configure), [monitor](#monitor).

![DevOps Lifecycle](img/devops_lifecycle.png)

### Plan

Whether you use Waterfall, Agile, or Conversational Development,
GitLab streamlines your collaborative workflows. Visualize, prioritize,
coordinate, and track your progress your way with GitLab’s flexible project
management tools.

- Chat operations
  - [Mattermost slash commands](user/project/integrations/mattermost_slash_commands.md)
  - [Slack slash commands](user/project/integrations/slack_slash_commands.md)
- [Discussions](user/discussions/index.md): Threads, comments, and resolvable discussions in issues, commits, and  merge requests.
- [Issues](user/project/issues/index.md)
- [Project Issue Board](user/project/issue_board.md)
- [Issues and merge requests templates](user/project/description_templates.md): Create templates for submitting new issues and merge requests.
- [Labels](user/project/labels.md): Categorize your issues or merge requests based on descriptive titles.
- [Milestones](user/project/milestones/index.md): Organize issues and merge requests into a cohesive group, optionally setting a due date.
- [Todos](workflow/todos.md): A chronological list of to-dos that are waiting for your input, all in a simple dashboard.
- [GitLab Quick Actions](user/project/quick_actions.md): Textual shortcuts for common actions on issues or merge requests that are usually done by clicking buttons or dropdowns in GitLab's UI.

#### Migrate and import your projects from other platforms

- [Importing to GitLab](user/project/import/index.md): Import your projects from GitHub, Bitbucket, GitLab.com, FogBugz and SVN into GitLab.
- [Migrating from SVN](workflow/importing/migrating_from_svn.md): Convert a SVN repository to Git and GitLab.

### Create

Consolidate source code into a single [DVCS](https://en.wikipedia.org/wiki/Distributed_version_control)
that’s easily managed and controlled without disrupting your workflow.
GitLab’s git repositories come complete with branching tools and access
controls, providing a scalable, single source of truth for collaborating
on projects and code.

#### Projects and groups

- [Projects](user/project/index.md):
  - [Project settings](user/project/settings/index.md)
  - [Create a project](gitlab-basics/create-project.md)
  - [Fork a project](gitlab-basics/fork-project.md)
  - [Importing and exporting projects between instances](user/project/settings/import_export.md).
  - [Project access](public_access/public_access.md): Setting up your project's visibility to public, internal, or private.
  - [GitLab Pages](user/project/pages/index.md): Build, test, and deploy your static website with GitLab Pages.
- [Groups](user/group/index.md): Organize your projects in groups.
  - [Subgroups](user/group/subgroups/index.md)
- [Search through GitLab](user/search/index.md): Search for issues, merge requests, projects, groups, todos, and issues in Issue Boards.
- [Snippets](user/snippets.md): Snippets allow you to create little bits of code.
- [Wikis](user/project/wiki/index.md): Enhance your repository documentation with built-in wikis.
- [Web IDE](user/project/web_ide/index.md)

#### Repositories

Manage your [repositories](user/project/repository/index.md) from the UI (user interface):

- [Files](user/project/repository/index.md#files)
  - [Create a file](user/project/repository/web_editor.md#create-a-file)
  - [Upload a file](user/project/repository/web_editor.md#upload-a-file)
  - [File templates](user/project/repository/web_editor.md#template-dropdowns)
  - [Jupyter Notebook files](user/project/repository/index.md#jupyter-notebook-files)
  - [Create a directory](user/project/repository/web_editor.md#create-a-directory)
  - [Start a merge request](user/project/repository/web_editor.md#tips) (when committing via UI)
- [Branches](user/project/repository/branches/index.md)
  - [Default branch](user/project/repository/branches/index.md#default-branch)
  - [Create a branch](user/project/repository/web_editor.md#create-a-new-branch)
  - [Protected branches](user/project/protected_branches.md#protected-branches)
  - [Delete merged branches](user/project/repository/branches/index.md#delete-merged-branches)
- [Commits](user/project/repository/index.md#commits)
  - [Signing commits](user/project/repository/gpg_signed_commits/index.md): use GPG to sign your commits.

#### Merge Requests

- [Merge Requests](user/project/merge_requests/index.md)
  - [Work In Progress "WIP" Merge Requests](user/project/merge_requests/work_in_progress_merge_requests.md)
  - [Merge Request discussion resolution](user/discussions/index.md#moving-a-single-discussion-to-a-new-issue): Resolve discussions, move discussions in a merge request to an issue, only allow merge requests to be merged if all discussions are resolved.
  - [Checkout merge requests locally](user/project/merge_requests/index.md#checkout-merge-requests-locally)
  - [Cherry-pick](user/project/merge_requests/cherry_pick_changes.md)

#### Integrations

- [Project Services](user/project/integrations/project_services.md): Integrate a project with external services, such as CI and chat.
- [GitLab Integration](integration/README.md): Integrate with multiple third-party services with GitLab to allow external issue trackers and external authentication.
- [Trello Power-Up](integration/trello_power_up.md): Integrate with GitLab's Trello Power-Up

#### Automation

- [API](api/README.md): Automate GitLab via a simple and powerful API.
- [GitLab Webhooks](user/project/integrations/webhooks.md): Let GitLab notify you when new code has been pushed to your project.

### Verify

Spot errors sooner, improve security and shorten feedback cycles with built-in
static code analysis, code testing, code quality, dependency checking and review
apps. Customize your approval workflow controls, automatically test the quality
of your code, and spin up a staging environment for every code change. GitLab
Continuous Integration is the most popular next generation testing system that
scales to run your tests faster.

- [GitLab CI/CD](ci/README.md): Explore the features and capabilities of Continuous Integration, Continuous Delivery, and Continuous Deployment with GitLab.
- [Review Apps](ci/review_apps/index.md): Preview changes to your app right from a merge request.
- [Pipeline Graphs](ci/pipelines.md#pipeline-graphs)

### Package

GitLab Container Registry gives you the enhanced security and access controls of
custom Docker images without 3rd party add-ons. Easily upload and download images
from GitLab CI/CD with full Git repository management integration.

- [GitLab Container Registry](user/project/container_registry.md): Learn how to use GitLab's built-in Container Registry.

### Release

Spend less time configuring your tools, and more time creating. Whether you’re
deploying to one server or thousands, build, test, and release your code
confidently and securely with GitLab’s built-in Continuous Delivery and Deployment.

- [Auto Deploy](topics/autodevops/index.md#auto-deploy): Configure GitLab CI for the deployment of your application.
- [Environments and deployments](ci/environments.md): With environments, you can control the continuous deployment of your software within GitLab.
- [GitLab Pages](user/project/pages/index.md): Build, test, and deploy a static site directly from GitLab.
- [Scheduled Pipelines](user/project/pipelines/schedules.md)
- [Protected Runners](ci/runners/README.md#protected-runners)

### Configure

Automate your entire workflow from build to deploy and monitoring with GitLab
Auto Devops. Best practice templates get you started with minimal to zero
configuration. Then customize everything from buildpacks to CI/CD.

- [Auto DevOps](topics/autodevops/index.md)
- [Deployment of Helm, Ingress, and Prometheus on Kubernetes](user/project/clusters/index.md#installing-applications)
- [Protected variables](ci/variables/README.md#protected-variables)
- [Easy creation of Kubernetes clusters on GKE](user/project/clusters/index.md#adding-and-creating-a-new-gke-cluster-via-gitlab)

### Monitor

Measure how long it takes to go from planning to monitoring and ensure your
applications are always responsive and available. GitLab collects and displays
performance metrics for deployed apps using Prometheus so you can know in an
instant how code changes impact your production environment.

- [GitLab Prometheus](administration/monitoring/prometheus/index.md): Configure the bundled Prometheus to collect various metrics from your GitLab instance.
- [Prometheus project integration](user/project/integrations/prometheus.md): Configure the Prometheus integration per project and monitor your CI/CD environments.
- [Prometheus metrics](user/project/integrations/prometheus_library/metrics.md): Let Prometheus collect metrics from various services, like Kubernetes, NGINX, NGINX ingress controller, HAProxy, and Amazon Cloud Watch.
- [GitLab Performance Monitoring](administration/monitoring/performance/index.md): Use InfluxDB and Grafana to monitor the performance of your GitLab instance (will be eventually replaced by Prometheus).
- [Health check](user/admin_area/monitoring/health_check.md): GitLab provides liveness and readiness probes to indicate service health and reachability to required services.
- [GitLab Cycle Analytics](user/project/cycle_analytics.md): Cycle Analytics measures the time it takes to go from an [idea to production](https://about.gitlab.com/2016/08/05/continuous-integration-delivery-and-deployment-with-gitlab/#from-idea-to-production-with-gitlab) for each project you have.

## Getting started with GitLab

- [GitLab Basics](gitlab-basics/README.md): Start working on your command line and on GitLab.
- [GitLab Workflow](workflow/README.md): Enhance your workflow with the best of GitLab Workflow.
  - See also [GitLab Workflow - an overview](https://about.gitlab.com/2016/10/25/gitlab-workflow-an-overview/).
- [GitLab Markdown](user/markdown.md): GitLab's advanced formatting system (GitLab Flavored Markdown).

### User account

- [User account](user/profile/index.md): Manage your account
  - [Authentication](topics/authentication/index.md): Account security with two-factor authentication, setup your ssh keys and deploy keys for secure access to your projects.
  - [Profile settings](user/profile/index.md#profile-settings): Manage your profile settings, two factor authentication and more.
- [User permissions](user/permissions.md): Learn what each role in a project (external/guest/reporter/developer/maintainer/owner) can do.

### Git and GitLab

- [Git](topics/git/index.md): Getting started with Git, branching strategies, Git LFS, advanced use.
- [Git cheatsheet](https://about.gitlab.com/images/press/git-cheat-sheet.pdf): Download a PDF describing the most used Git operations.
- [GitLab Flow](workflow/gitlab_flow.md): explore the best of Git with the GitLab Flow strategy.

## Administrator documentation

[Administration documentation](administration/index.md) applies to admin users of GitLab
self-hosted instances.

Learn how to install, configure, update, upgrade, integrate, and maintain your own instance.
Regular users don't have access to GitLab administration tools and settings.

## Contributor documentation

GitLab Community Edition is [open source](https://gitlab.com/gitlab-org/gitlab-ce/)
and GitLab Enterprise Edition is [open-core](https://gitlab.com/gitlab-org/gitlab-ee/).
Learn how to contribute to GitLab:

- [Development](development/README.md): All styleguides and explanations how to contribute.
- [Legal](legal/README.md): Contributor license agreements.
- [Writing documentation](development/documentation/index.md): Contributing to GitLab Docs.

## GitLab subscriptions

You have two options to use GitLab:

- GitLab self-hosted: Install, administer, and maintain your own GitLab instance.
- GitLab.com: GitLab's SaaS offering. You don't need to install anything to use GitLab.com,
you only need to [sign up](https://gitlab.com/users/sign_in) and start using GitLab
straight away.

### GitLab self-hosted

With GitLab self-hosted, you deploy your own GitLab instance on-premises or on a private cloud of your choice. GitLab self-hosted is available for [free and with paid subscriptions](https://about.gitlab.com/pricing/): Core, Starter, Premium, and Ultimate.

Every feature available in Core is also available in Starter, Premium, and Ultimate.
Starter features are also available in Premium and Ultimate, and Premium features are also
available in Ultimate.

### GitLab.com

GitLab.com is hosted, managed, and administered by GitLab, Inc., with
[free and paid subscriptions](https://about.gitlab.com/gitlab-com/) for individuals
and teams: Free, Bronze, Silver, and Gold.

GitLab.com subscriptions grants access
to the same features available in GitLab self-hosted, **except
[administration](administration/index.md) tools and settings**:

- GitLab.com Free includes the same features available in Core
- GitLab.com Bronze includes the same features available in GitLab Starter
- GitLab.com Silver includes the same features available in GitLab Premium
- GitLab.com Gold includes the same features available in GitLab Ultimate

For supporting the open source community and encouraging the development of
open source projects, GitLab grants access to **Gold** features
for all GitLab.com **public** projects, regardless of the subscription.

To know more about GitLab subscriptions and licensing, please refer to the
[GitLab Product Marketing Handbook](https://about.gitlab.com/handbook/marketing/product-marketing/#tiers).
