import Vue from 'vue';
import store from '~/ide/stores';
import { activityBarViews } from '~/ide/constants';
import ActivityBar from '~/ide/components/activity_bar.vue';
import { createComponentWithStore } from '../../helpers/vue_mount_component_helper';
import { resetStore } from '../helpers';

describe('IDE activity bar', () => {
  const Component = Vue.extend(ActivityBar);
  let vm;

  beforeEach(() => {
    Vue.set(store.state.projects, 'abcproject', {
      web_url: 'testing',
    });
    Vue.set(store.state, 'currentProjectId', 'abcproject');

    vm = createComponentWithStore(Component, store);
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);
  });

  describe('goBackUrl', () => {
    it('renders the Go Back link with the referrer when present', () => {
      const fakeReferrer = '/example/README.md';
      spyOnProperty(document, 'referrer').and.returnValue(fakeReferrer);

      vm.$mount();

      expect(vm.goBackUrl).toEqual(fakeReferrer);
    });

    it('renders the Go Back link with the project url when referrer is not present', () => {
      const fakeReferrer = '';
      spyOnProperty(document, 'referrer').and.returnValue(fakeReferrer);

      vm.$mount();

      expect(vm.goBackUrl).toEqual('testing');
    });
  });

  describe('updateActivityBarView', () => {
    beforeEach(() => {
      spyOn(vm, 'updateActivityBarView');

      vm.$mount();
    });

    it('calls updateActivityBarView with edit value on click', () => {
      vm.$el.querySelector('.js-ide-edit-mode').click();

      expect(vm.updateActivityBarView).toHaveBeenCalledWith(activityBarViews.edit);
    });

    it('calls updateActivityBarView with commit value on click', () => {
      vm.$el.querySelector('.js-ide-commit-mode').click();

      expect(vm.updateActivityBarView).toHaveBeenCalledWith(activityBarViews.commit);
    });

    it('calls updateActivityBarView with review value on click', () => {
      vm.$el.querySelector('.js-ide-review-mode').click();

      expect(vm.updateActivityBarView).toHaveBeenCalledWith(activityBarViews.review);
    });
  });

  describe('active item', () => {
    beforeEach(() => {
      vm.$mount();
    });

    it('sets edit item active', () => {
      expect(vm.$el.querySelector('.js-ide-edit-mode').classList).toContain('active');
    });

    it('sets commit item active', done => {
      vm.$store.state.currentActivityView = activityBarViews.commit;

      vm.$nextTick(() => {
        expect(vm.$el.querySelector('.js-ide-commit-mode').classList).toContain('active');

        done();
      });
    });
  });
});
