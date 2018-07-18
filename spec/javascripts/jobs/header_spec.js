import Vue from 'vue';
import headerComponent from '~/jobs/components/header.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Job details header', () => {
  let HeaderComponent;
  let vm;
  let props;

  beforeEach(() => {
    HeaderComponent = Vue.extend(headerComponent);

    const threeWeeksAgo = new Date();
    threeWeeksAgo.setDate(threeWeeksAgo.getDate() - 21);

    const twoDaysAgo = new Date();
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

    props = {
      job: {
        status: {
          group: 'failed',
          icon: 'ci-status-failed',
          label: 'failed',
          text: 'failed',
          details_path: 'path',
        },
        id: 123,
        created_at: threeWeeksAgo.toISOString(),
        user: {
          web_url: 'path',
          name: 'Foo',
          username: 'foobar',
          email: 'foo@bar.com',
          avatar_url: 'link',
        },
        started: twoDaysAgo.toISOString(),
        new_issue_path: 'path',
      },
      isLoading: false,
    };
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('job reason', () => {
    it('should not render the reason when reason is absent', () => {
      vm = mountComponent(HeaderComponent, props);

      expect(vm.shouldRenderReason).toBe(false);
    });

    it('should render the reason when reason is present', () => {
      props.job.callout_message = 'There is an unknown failure, please try again';

      vm = mountComponent(HeaderComponent, props);

      expect(vm.shouldRenderReason).toBe(true);
    });
  });

  describe('triggered job', () => {
    beforeEach(() => {
      vm = mountComponent(HeaderComponent, props);
    });

    it('should render provided job information', () => {
      expect(
        vm.$el
          .querySelector('.header-main-content')
          .textContent.replace(/\s+/g, ' ')
          .trim(),
      ).toEqual('failed Job #123 triggered 2 days ago by Foo');
    });

    it('should render new issue link', () => {
      expect(vm.$el.querySelector('.js-new-issue').getAttribute('href')).toEqual(
        props.job.new_issue_path,
      );
    });
  });

  describe('created job', () => {
    it('should render created key', () => {
      props.job.started = false;
      vm = mountComponent(HeaderComponent, props);

      expect(
        vm.$el
          .querySelector('.header-main-content')
          .textContent.replace(/\s+/g, ' ')
          .trim(),
      ).toEqual('failed Job #123 created 3 weeks ago by Foo');
    });
  });
});
