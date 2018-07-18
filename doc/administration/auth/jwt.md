# JWT OmniAuth provider

To enable the JWT OmniAuth provider, you must register your application with JWT.
JWT will provide you with a secret key for you to use.

1.  On your GitLab server, open the configuration file.

    For Omnibus GitLab:

    ```sh
    sudo editor /etc/gitlab/gitlab.rb
    ```

    For installations from source:

    ```sh
    cd /home/git/gitlab
    sudo -u git -H editor config/gitlab.yml
    ```

1.  See [Initial OmniAuth Configuration](../../integration/omniauth.md#initial-omniauth-configuration) for initial settings.
1.  Add the provider configuration.

    For Omnibus GitLab:

    ```ruby
    gitlab_rails['omniauth_providers'] = [
      { name: 'jwt',
        app_secret: 'YOUR_APP_SECRET',
        args: {
                algorithm: 'HS256',
                uid_claim: 'email',
                required_claims: ["name", "email"],
                info_maps: { name: "name", email: "email" },
                auth_url: 'https://example.com/',
                valid_within: nil,
              }
      }
    ]
    ```

    For installation from source:

    ```
    - { name: 'jwt',
        app_secret: 'YOUR_APP_SECRET',
        args: {
                algorithm: 'HS256',
                uid_claim: 'email',
                required_claims: ["name", "email"],
                info_map: { name: "name", email: "email" },
                auth_url: 'https://example.com/',
                valid_within: null,
              }
      }
    ```

    NOTE: **Note:** For more information on each configuration option refer to
    the [OmniAuth JWT usage documentation](https://github.com/mbleigh/omniauth-jwt#usage).

1.  Change `YOUR_APP_SECRET` to the client secret and set `auth_url` to your redirect URL.
1.  Save the configuration file.
1.  [Reconfigure GitLab][] or [restart GitLab][] for the changes to take effect if you
    installed GitLab via Omnibus or from source respectively.

On the sign in page there should now be a JWT icon below the regular sign in form.
Click the icon to begin the authentication process. JWT will ask the user to
sign in and authorize the GitLab application. If everything goes well, the user
will be redirected to GitLab and will be signed in.

[reconfigure GitLab]: ../restart_gitlab.md#omnibus-gitlab-reconfigure
[restart GitLab]: ../restart_gitlab.md#installations-from-source
