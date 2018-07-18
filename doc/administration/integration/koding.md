# Koding & GitLab

>**Notes:**
- **As of GitLab 10.0, the Koding integration is deprecated and will be removed
  in a future version. The option to configure it is removed from GitLab's admin
  area.**
- [Introduced][ce-5909] in GitLab 8.11.

This document will guide you through installing and configuring Koding with
GitLab.

First of all, to be able to use Koding and GitLab together you will need public
access to your server. This allows you to use single sign-on from GitLab to
Koding and using vms from cloud providers like AWS. Koding has a registry for
VMs, called Kontrol and it runs on the same server as Koding itself, VMs from
cloud providers register themselves to Kontrol via the agent that we put into
provisioned VMs. This agent is called Klient and it provides Koding to access
and manage the target machine.

Kontrol and Klient are based on another technology called
[Kite](https://github.com/koding/kite), that we have written at Koding. Which is a
microservice framework that allows you to develop microservices easily.

## Requirements

### Hardware

Minimum requirements are;

  - 2 cores CPU
  - 3G RAM
  - 10G Storage

If you plan to use AWS to install Koding it is recommended that you use at
least a `c3.xlarge` instance.

### Software

  - [Git](https://git-scm.com)
  - [Docker](https://www.docker.com)
  - [docker-compose](https://www.docker.com/products/docker-compose)

Koding can run on most of the UNIX based operating systems, since it's shipped
as containerized with Docker support, it can work on any operating system that
supports Docker.

Required services are:

- **PostgreSQL** - Kontrol and Service DB provider
- **MongoDB**    - Main DB provider the application
- **Redis**      - In memory DB used by both application and services
- **RabbitMQ**   - Message Queue for both application and services

which are also provided as a Docker container by Koding.


## Getting Started with Development Versions


### Koding

You can run `docker-compose` environment for developing koding by
executing commands in the following snippet.

```bash
git clone https://github.com/koding/koding.git
cd koding
docker-compose -f docker-compose-init.yml run init
docker-compose up
```

This should start koding on `localhost:8090`.

By default there is no team exists in Koding DB. You'll need to create a team
called `gitlab` which is the default team name for GitLab integration in the
configuration. To make things in order it's recommended to create the `gitlab`
team first thing after setting up Koding.


### GitLab

To install GitLab to your environment for development purposes it's recommended
to use GitLab Development Kit which you can get it from
[here](https://gitlab.com/gitlab-org/gitlab-development-kit).

After all those steps, gitlab should be running on `localhost:3000`


## Integration

Integration includes following components;

  - Single Sign On with OAuth from GitLab to Koding
  - System Hook integration for handling GitLab events on Koding
    (`project_created`, `user_joined` etc.)
  - Service endpoints for importing/executing stacks from GitLab to Koding
    (`Run/Try on IDE (Koding)` buttons on GitLab Projects, Issues, MRs)

As it's pointed out before, you will need public access to this machine that
you've installed Koding and GitLab on. Better to use a domain but a static IP
is also fine.

For IP based installation you can use [nip.io](https://nip.io) service which is
free and provides DNS resolution to IP based requests like following;

  - 127.0.0.1.nip.io              -> resolves to 127.0.0.1
  - foo.bar.baz.127.0.0.1.nip.io  -> resolves to 127.0.0.1
  - and so on...

As Koding needs subdomains for team names; `foo.127.0.0.1.nip.io` requests for
a running koding instance on `127.0.0.1` server will be handled as `foo` team
requests.


### GitLab Side

You need to enable Koding integration from Settings under Admin Area. To do
that login with an Admin account and do followings;

 - open [http://127.0.0.1:3000/admin/application_settings](http://127.0.0.1:3000/admin/application_settings)
 - scroll to bottom of the page until Koding section
 - check `Enable Koding` checkbox
 - provide GitLab team page for running Koding instance as `Koding URL`*

* For `Koding URL` you need to provide the gitlab integration enabled team on
your Koding installation. Team called `gitlab` has integration on Koding out
of the box, so if you didn't change anything your team on Koding should be
`gitlab`.

So, if your Koding is running on `http://1.2.3.4.nip.io:8090` your URL needs
to be `http://gitlab.1.2.3.4.nip.io:8090`. You need to provide the same host
with your Koding installation here.


#### Registering Koding for OAuth integration

We need `Application ID` and `Secret` to enable login to Koding via GitLab
feature and to do that you need to register running Koding as a new application
to your running GitLab application. Follow
[these](http://docs.gitlab.com/ce/integration/oauth_provider.html) steps to
enable this integration.

Redirect URI should be `http://gitlab.127.0.0.1:8090/-/oauth/gitlab/callback`
which again you need to _replace `127.0.0.1` with your instance public IP._

Take a copy of `Application ID` and `Secret` that is generated by the GitLab
application, we will need those on _Koding Part_ of this guide.


#### Registering system hooks to Koding (optional)

Koding can take actions based on the events generated by GitLab application.
This feature is still in progress and only following events are processed by
Koding at the moment;

  - user_create
  - user_destroy

All system events are handled but not implemented on Koding side.

To enable this feature you need to provide a `URL` and a `Secret Token` to your
GitLab application. Open your admin area on your GitLab app from
[http://127.0.0.1:3000/admin/hooks](http://127.0.0.1:3000/admin/hooks)
and provide `URL` as `http://gitlab.127.0.0.1:8090/-/api/gitlab` which is the
endpoint to handle GitLab events on Koding side. Provide a `Secret Token` and
keep a copy of it, we will need it on _Koding Part_ of this guide.

_(replace `127.0.0.1` with your instance public IP)_


### Koding Part

If you followed the steps in GitLab part we should have followings to enable
Koding part integrations;

  - `Application ID` and `Secret` for OAuth integration
  - `Secret Token` for system hook integration
  - Public address of running GitLab instance


#### Start Koding with GitLab URL

Now we need to configure Koding with all this information to get things ready.
If it's already running please stop koding first.

##### From command-line

Replace followings with the ones you got from GitLab part of this guide;

```bash
cd koding
docker-compose run                              \
  --service-ports backend                       \
  /opt/koding/scripts/bootstrap-container build \
  --host=**YOUR_IP**.nip.io                     \
  --gitlabHost=**GITLAB_IP**                    \
  --gitlabPort=**GITLAB_PORT**                  \
  --gitlabToken=**SECRET_TOKEN**                \
  --gitlabAppId=**APPLICATION_ID**              \
  --gitlabAppSecret=**SECRET**
```

##### By updating configuration

Alternatively you can update `gitlab` section on
`config/credentials.default.coffee` like following;

```
gitlab =
  host: '**GITLAB_IP**'
  port: '**GITLAB_PORT**'
  applicationId: '**APPLICATION_ID**'
  applicationSecret: '**SECRET**'
  team: 'gitlab'
  redirectUri: ''
  systemHookToken: '**SECRET_TOKEN**'
  hooksEnabled: yes
```

and start by only providing the `host`;

```bash
cd koding
docker-compose run                              \
  --service-ports backend                       \
  /opt/koding/scripts/bootstrap-container build \
  --host=**YOUR_IP**.nip.io                     \
```

#### Enable Single Sign On

Once you restarted your Koding and logged in with your username and password
you need to activate oauth authentication for your user. To do that

 - Navigate to Dashboard on Koding from;
   `http://gitlab.**YOUR_IP**.nip.io:8090/Home/my-account`
 - Scroll down to Integrations section
 - Click on toggle to turn On integration in GitLab integration section

This will redirect you to your GitLab instance and will ask your permission (
if you are not logged in to GitLab at this point you will be redirected after
login) once you accept you will be redirected to your Koding instance.

From now on you can login by using `SIGN IN WITH GITLAB` button on your Login
screen in your Koding instance.

[ce-5909]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/5909
