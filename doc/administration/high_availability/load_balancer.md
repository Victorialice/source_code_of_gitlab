# Load Balancer for GitLab HA

In an active/active GitLab configuration, you will need a load balancer to route
traffic to the application servers. The specifics on which load balancer to use
or the exact configuration is beyond the scope of GitLab documentation. We hope
that if you're managing HA systems like GitLab you have a load balancer of
choice already. Some examples including HAProxy (open-source), F5 Big-IP LTM,
and Citrix Net Scaler. This documentation will outline what ports and protocols
you need to use with GitLab.

## Basic ports

| LB Port | Backend Port | Protocol        |
| ------- | ------------ | --------------- |
| 80      | 80           | HTTP  [^1]      |
| 443     | 443          | TCP or HTTPS [^1] [^2] |
| 22      | 22           | TCP             |

## GitLab Pages Ports

If you're using GitLab Pages with custom domain support you will need some 
additional port configurations.
GitLab Pages requires a separate virtual IP address. Configure DNS to point the
`pages_external_url` from `/etc/gitlab/gitlab.rb` at the new virtual IP address. See the
[GitLab Pages documentation][gitlab-pages] for more information.

| LB Port | Backend Port | Protocol |
| ------- | ------------ | -------- |
| 80      | Varies [^3]  | HTTP     |
| 443     | Varies [^3]  | TCP [^4] |

## Alternate SSH Port

Some organizations have policies against opening SSH port 22. In this case,
it may be helpful to configure an alternate SSH hostname that allows users
to use SSH on port 443. An alternate SSH hostname will require a new virtual IP address
compared to the other GitLab HTTP configuration above.

Configure DNS for an alternate SSH hostname such as altssh.gitlab.example.com.

| LB Port | Backend Port | Protocol |
| ------- | ------------ | -------- |
| 443     | 22           | TCP      |

---

Read more on high-availability configuration:

1. [Configure the database](database.md)
1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the GitLab application servers](gitlab.md)

[^1]: [Web terminal](../../ci/environments.md#web-terminals) support requires
      your load balancer to correctly handle WebSocket connections. When using
      HTTP or HTTPS proxying, this means your load balancer must be configured
      to pass through the `Connection` and `Upgrade` hop-by-hop headers. See the
      [web terminal](../integration/terminal.md) integration guide for
      more details.
[^2]: When using HTTPS protocol for port 443, you will need to add an SSL
      certificate to the load balancers. If you wish to terminate SSL at the
      GitLab application server instead, use TCP protocol.
[^3]: The backend port for GitLab Pages depends on the
      `gitlab_pages['external_http']` and `gitlab_pages['external_https']`
      setting. See [GitLab Pages documentation][gitlab-pages] for more details.
[^4]: Port 443 for GitLab Pages should always use the TCP protocol. Users can
      configure custom domains with custom SSL, which would not be possible
      if SSL was terminated at the load balancer.

[gitlab-pages]: ../pages/index.md
