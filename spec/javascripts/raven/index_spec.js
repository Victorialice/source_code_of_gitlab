import RavenConfig from '~/raven/raven_config';
import index from '~/raven/index';

describe('RavenConfig options', () => {
  const sentryDsn = 'sentryDsn';
  const currentUserId = 'currentUserId';
  const gitlabUrl = 'gitlabUrl';
  const isProduction = 'isProduction';
  const revision = 'revision';
  let indexReturnValue;

  beforeEach(() => {
    window.gon = {
      sentry_dsn: sentryDsn,
      current_user_id: currentUserId,
      gitlab_url: gitlabUrl,
      revision,
    };

    process.env.NODE_ENV = isProduction;
    process.env.HEAD_COMMIT_SHA = revision;

    spyOn(RavenConfig, 'init');

    indexReturnValue = index();
  });

  it('should init with .sentryDsn, .currentUserId, .whitelistUrls and .isProduction', () => {
    expect(RavenConfig.init).toHaveBeenCalledWith({
      sentryDsn,
      currentUserId,
      whitelistUrls: [gitlabUrl],
      isProduction,
      release: revision,
      tags: {
        revision,
      },
    });
  });

  it('should return RavenConfig', () => {
    expect(indexReturnValue).toBe(RavenConfig);
  });
});
