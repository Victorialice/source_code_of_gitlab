# Container Scanning with GitLab CI/CD

You can check your Docker images (or more precisely the containers) for known
vulnerabilities by using [Clair](https://github.com/coreos/clair) and
[clair-scanner](https://github.com/arminc/clair-scanner), two open source tools
for Vulnerability Static Analysis for containers.

All you need is a GitLab Runner with the Docker executor (the shared Runners on
GitLab.com will work fine). You can then add a new job to `.gitlab-ci.yml`,
called `container_scanning`:

```yaml
container_scanning:
  image: docker:stable
  variables:
    DOCKER_DRIVER: overlay2
    ## Define two new variables based on GitLab's CI/CD predefined variables
    ## https://docs.gitlab.com/ee/ci/variables/#predefined-variables-environment-variables
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG
    CI_APPLICATION_TAG: $CI_COMMIT_SHA
  allow_failure: true
  services:
    - docker:stable-dind
  script:
    - docker run -d --name db arminc/clair-db:latest
    - docker run -p 6060:6060 --link db:postgres -d --name clair --restart on-failure arminc/clair-local-scan:v2.0.1
    - apk add -U wget ca-certificates
    - docker pull ${CI_APPLICATION_REPOSITORY}:${CI_APPLICATION_TAG}
    - wget https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64
    - mv clair-scanner_linux_amd64 clair-scanner
    - chmod +x clair-scanner
    - touch clair-whitelist.yml
    - while( ! wget -q -O /dev/null http://docker:6060/v1/namespaces ) ; do sleep 1 ; done
    - retries=0
    - echo "Waiting for clair daemon to start"
    - while( ! wget -T 10 -q -O /dev/null http://docker:6060/v1/namespaces ) ; do sleep 1 ; echo -n "." ; if [ $retries -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; retries=$(($retries+1)) ; done
    - ./clair-scanner -c http://docker:6060 --ip $(hostname -i) -r gl-container-scanning-report.json -l clair.log -w clair-whitelist.yml ${CI_APPLICATION_REPOSITORY}:${CI_APPLICATION_TAG} || true
  artifacts:
    paths: [gl-container-scanning-report.json]
```

The above example will create a `container_scanning` job in your CI/CD pipeline, pull
the image from the [Container Registry](../../user/project/container_registry.md)
(whose name is defined from the two `CI_APPLICATION_` variables) and scan it
for possible vulnerabilities. The report will be saved as an artifact that you
can later download and analyze.

If you want to whitelist some specific vulnerabilities, you can do so by defining
them in a [YAML file](https://github.com/arminc/clair-scanner/blob/master/README.md#example-whitelist-yaml-file),
in our case its named `clair-whitelist.yml`.

TIP: **Tip:**
Starting with [GitLab Ultimate][ee] 10.4, this information will
be automatically extracted and shown right in the merge request widget. To do
so, the CI/CD job must be named `container_scanning` and the artifact path must be
`gl-container-scanning-report.json`.
[Learn more on container scanning results shown in merge requests](https://docs.gitlab.com/ee/user/project/merge_requests/container_scanning.html).

CAUTION: **Caution:**
Before GitLab 11.0, Container Scanning was previously using `sast:container` for job name and
`gl-sast-container-report.json` for the artifact name. While these old names
are still maintained, they have been deprecated with GitLab 11.0 and may be removed
in next major release, GitLab 12.0. You are advised to update your current `.gitlab-ci.yml`
configuration to reflect that change.

[ee]: https://about.gitlab.com/pricing/
